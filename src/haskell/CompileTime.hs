module CompileTime where

import AbsChapel
import Data.Maybe
import Data.Char -- ord, chr
import TCType
import TCInstances
import Control.Monad (guard)
import Env
import qualified ErrM as EM


-- Literal coercions /////////////////////////////////////////////////////////////

toLInt :: Literal -> Literal
toLInt (LBool a)    = LInt . toInteger $ if a then 1 else 0
toLInt (LChar a)    = LInt . toInteger . ord $ a
toLInt i@(LInt _)   = i
-- undefined patterns

toLReal :: Literal -> Literal
toLReal b@(LBool a) = toLReal . toLInt $ b
toLReal c@(LChar a) = toLReal . toLInt $ c
toLReal (LInt a)    = LReal . fromInteger $ a
toLReal r@(LReal _) = r
-- undefined patterns


-- Binary operation overloading abstractions ///////////////////////////////////////
type LIntOperator    = Literal -> Literal -> Maybe Literal
type LRealOperator   = Literal -> Literal -> Maybe Literal
type LiteralOperator = Literal -> Literal -> Maybe Literal

intBinary :: (Integer -> Integer -> Integer) -> LIntOperator
intBinary op = \x y -> case (x,y) of
    (LInt a, LInt b) -> Just . LInt $ a `op` b
    _                -> Nothing

realBinary :: (Double -> Double -> Double) -> LRealOperator
realBinary op = \x y -> case (x,y) of
    (LReal a, LReal b) -> Just . LReal $ a `op` b
    _                -> Nothing


-- 2. Abstraction on the overloading check

-- overload abstracts the process of overloading given an int and a real version of an operator
overload :: LIntOperator -> LRealOperator -> LiteralOperator
overload intOp realOp = \x y -> case (x, y) of
    (LBool _, _)        -> overload intOp realOp (toLInt x) y
    (LChar _, _)        -> overload intOp realOp (toLInt x) y
    (LInt _, LBool _)   -> x `intOp` (toLInt y)
    (LInt _, LChar _)   -> x `intOp` (toLInt y)
    (LInt _, LInt _)    -> x `intOp` y
    (LInt _, LReal _)   -> overload intOp realOp (toLReal x) y
    (LReal _, LBool _)  -> x `realOp` (toLReal y)
    (LReal _, LChar _)  -> x `realOp` (toLReal y)
    (LReal _, LInt _)   -> x `realOp` (toLReal y)
    (LReal _, LReal _)  -> x `realOp` y
    _                   -> Nothing


-- Concrete addition ////////////////////////////////////////////////////////////////

intAdd :: LIntOperator
intAdd = intBinary (+)

realAdd :: LRealOperator
realAdd = realBinary (+)

litAdd :: LiteralOperator
x `litAdd` y = overload intAdd realAdd x y



-- Concrete subtraction ////////////////////////////////////////////////////////////////

intSub :: LIntOperator
intSub = intBinary (-)

realSub :: LRealOperator
realSub = realBinary (-)

litSub :: LiteralOperator
litSub = overload intSub realSub

-- Concrete multiplication ////////////////////////////////////////////////////////////

intMul :: LIntOperator
intMul = intBinary (*)

realMul :: LRealOperator
realMul = realBinary (*)

litMul :: LiteralOperator
litMul = overload intMul realMul

-- Concrete division //////////////////////////////////////////////////////////////////

intDiv :: LIntOperator
intDiv = intBinary div

realDiv :: LRealOperator
realDiv = realBinary (/)

litDiv :: LiteralOperator
litDiv = overload intDiv realDiv

-- Concrete exponentiation ///////////////////////////////////////////////////////////

litPow :: LiteralOperator
x `litPow` b@(LBool _) = x `litPow` (toLInt b)
x `litPow` c@(LChar _) = x `litPow` (toLInt c)

x `litPow` y@(LInt e) = case x of
    LBool _     -> (toLInt x) `litPow` y
    LChar _     -> (toLInt x) `litPow` y
    LInt a      -> Just . LInt $ a ^ e
    LReal a     -> Just . LReal $ a ^ e
    _           -> Nothing

_ `litPow` _ = Nothing -- undefined for non integer exponent

-- Concrete remainder ///////////////////////////////////////////////////////////////

litMod :: LiteralOperator
b@(LBool _) `litMod` x = (toLInt b) `litMod` x
c@(LChar _) `litMod` x = (toLInt c) `litMod` x

i@(LInt a) `litMod` x = case x of
    LBool _     -> i `litMod` (toLInt x)
    LChar _     -> i `litMod` (toLInt x)
    LInt  n     -> Just . LInt $ a `mod` n
    _           -> Nothing

_ `litMod` _ = Nothing -- undefined for non integer operands


-- Arithmetic dispatcher

litArith :: (ArithOp t) -> LiteralOperator
litArith x = case x of
    Add _ -> litAdd
    Sub _ -> litSub
    Mul _ -> litMul
    Div _ -> litDiv
    Mod   -> litMod
    Pow _ -> litPow



-- COMPARISON OPERATORS ////////////////////////////////////////////////////////////////

type LiteralComparison = Literal -> Literal -> Maybe Bool

data LitOrd = LitLT | LitEQ | LitGT | LitNC
    deriving (Eq, Show)

toLitOrd :: Ordering -> LitOrd
toLitOrd x = case x of
    LT  -> LitLT
    EQ  -> LitEQ
    GT  -> LitGT

-- Strict comparison
strictCompare :: Literal -> Literal -> LitOrd
strictCompare x y = case (x, y) of
    (LBool   a, LBool b)    -> toLitOrd $ a `compare` b
    (LChar   a, LChar b)    -> toLitOrd $ a `compare` b
    (LInt    a, LInt  b)    -> toLitOrd $ a `compare` b
    (LReal   a, LReal b)    -> toLitOrd $ a `compare` b
    (LString a, LString b)  -> toLitOrd $ a `compare` b
    _                       -> LitNC


-- Comparison with type compatibilities
overloadCompare :: Literal -> Literal -> LitOrd
overloadCompare x y = case (tctypeOf x) `supremum` (tctypeOf y) of
    TBool   -> x `strictCompare` y
    TChar   -> x `strictCompare` y
    TInt    -> (toLInt x)    `strictCompare` (toLInt y)
    TReal   -> (toLReal x)   `strictCompare` (toLReal y)
    TString -> x `strictCompare` y
    _       -> LitNC


-- Comparison operator dispatcher
litComp :: (CompOp t) -> LiteralComparison
litComp op = \x y -> let rel = x `overloadCompare` y in case rel of
    LitNC -> Nothing
    _     -> Just $ case op of
        Lt  _ -> rel == LitLT
        Leq _ -> rel == LitLT || rel == LitEQ
        Eq  _ -> rel == LitEQ
        Neq _ -> rel /= LitEQ
        Geq _ -> rel /= LitLT
        Gt  _ -> rel == LitGT



-- ARRAY ACCESS ///////////////////////////////////////////////////////////////////////

-- Access element at position i in an array of Literals
-- (Precondition) i must have tctype <= TInt
litAccess :: Literal -> Literal -> Maybe Literal
litAccess arr@(LArr _ lits) i = do
    let (LInt i') = toLInt i
    guard (i' < (toInteger . length $ lits))
    guard (0 <= i')
    return $ lits !! (fromInteger i')


-- CONSTEXPR //////////////////////////////////////////////////////////////////////////

-- Returns a literal if r is a compile-time constant expression,
-- Nothing otherwise.
-- (Precondition): r is semantically correct
constexpr :: Env -> RExp t -> Maybe Literal
constexpr env r = case r of
    Or _ r1 r2 _ -> do
        (LBool b1) <- constexpr env r1
        (LBool b2) <- constexpr env r2
        return . LBool $ b1 || b2

    And _ r1 r2 _ -> do
        (LBool b1) <- constexpr env r1
        (LBool b2) <- constexpr env r2
        return . LBool $ b1 && b2
    
    Not _ r _ -> do
        (LBool b) <- constexpr env r
        return . LBool $ not b
        
    Comp _ r1 op r2 _ -> do
        l1 <- constexpr env r1
        l2 <- constexpr env r2
        b  <- litComp op l1 l2
        return . LBool $ b

    Arith _ r1 op r2 _ -> do
        l1 <- constexpr env r1
        l2 <- constexpr env r2
        litArith op l1 l2

    Sign _ (Pos _) r _ -> constexpr env r

    Sign _ (Neg _) r _ -> do
        l <- constexpr env r
        case l of
            LChar a -> return . LInt . toInteger $ -(ord a)
            LInt  a -> return . LInt $ -a
            LReal a -> return . LReal $ -a
            _       -> Nothing

    RLExp _ l _ -> constexprL env l
    
    ArrList _ rs _ -> do
        let lits = map (constexpr env) rs                -- take list of Maybe literals recursively
        let t    = foldl1 supremum $ map tctypeOf lits   -- take unifier type
        guard (t /= TError)                              -- safety check

        let conv = case t of                             -- select coercion function based on more general type in lits
                    TInt    -> toLInt
                    TReal   -> toLReal
                    _       -> id

        return $ LArr False [ conv x | (Just x) <- lits ]

    Lit _ lit _ -> Just lit

    _ -> Nothing


constexprL :: Env -> LExp t -> Maybe Literal
constexprL env lexp = case lexp of
    Deref l _    -> Nothing

    Access l r _ -> do
        arr <- constexprL env l     -- take literal array
        i <- constexpr env r        -- take literal index
        litAccess arr i             -- return the accessed value

    Name ident _ -> do
        (Const _ _ lit) <- EM.errToMaybe $ lookConst ident env
        return lit