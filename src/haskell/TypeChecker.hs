module TypeChecker where

import AbsGarpezpp
import Data.Maybe


-- Given an RExp, returns Just the value of the RExp or Nothing in case of a non-const expression
-- const-expressions are those with only literals or id of constants
-- (To be done)
constexpr :: RExp -> Maybe Int
constexpr r = Just 5

-- Type annotation for the type-checker
data TCType 
    = TVoid
    | TBool
    | TChar
    | TInt
    | TFloat
    | TString
    | TPoint TCType
    | TArr (Int, TCType)
    | TFun (TCType, [(TCType, PassBy)])
    deriving (Show, Eq)

-- Class to have a "universal" converter to TCType
class TCTypeable a where
    toTCType :: a -> TCType


-- Basic types are TCTypes
instance TCTypeable Basic where
    toTCType x = case x of
        BBool -> TBool
        BChar -> TChar
        BInt -> TInt
        BFloat -> TFloat
        BString -> TString


-- Literals of some type have TCTypes
instance TCTypeable Literal where
    toTCType x = case x of
        LBool _ -> TBool
        LChar _ -> TChar
        LInt _ -> TInt
        LFloat _ -> TFloat
        LString _ -> TString

-- General Types are TCTypes
instance TCTypeable Type where
    toTCType x = case x of
        Type b Simple -> toTCType b
        Type b c -> helper (toTCType b) c where
            helper t c = case c of
                Simple -> t
                Pointer c' -> TPoint $ helper t c'
                Array c' r -> TArr (fromJust $ constexpr r, helper t c')

-- Return types are TCTypes
instance TCTypeable RType where
    toTCType x = case x of
        RVoid -> TVoid
        RBasic b -> toTCType b
        RRef t -> toTCType t

-- Function declarations have TCType
instance TCTypeable FDecl where
    toTCType (FDecl rt _ ps _) = TFun (r, ls) where
        r = toTCType rt
        ls = map (\(Param t p _) -> (toTCType t, p)) ps


-- TODO leastGeneral
-- leastGeneral :: TCType -> TCType -> ?? (To be decided what kind of Error to use)