module ErrorHandling where

import qualified ErrM as EM
import qualified ErrT as ET
import AbsChapel
import TCType
import TCInstances
import Locatable
import PrintChapel

lengthLimit :: Int
lengthLimit = 30

showLim :: (Show a) => a -> String
showLim a = 
    let s = show a
        s' = take lengthLimit s
    in (s'++) $ if (length s) > lengthLimit
        then "..."
        else ""

printLim :: (Print a) => a -> String
printLim a = 
    let s = printTree a
        s' = take lengthLimit s
    in (s'++) $ if (length s) > lengthLimit
        then "..."
        else ""


whenT :: a -> Bool -> EM.Err a -> ET.ErrT a
whenT a g v = 
    if g 
        then ET.toErrT a v 
        else return a

unlessT :: a -> Bool -> EM.Err a -> ET.ErrT a
unlessT a g v = whenT a (not g) v


badLoc :: Loc -> String -> EM.Err a
badLoc loc reason = EM.Bad $ (show loc) ++ ": Error! " ++ reason ++ "."



errorMissingMain :: EM.Err a
errorMissingMain = EM.Bad $ "Error! Missing 'main' procedure of signature 'void main ()'."


errorLogicOperand :: String -> RExp t -> TCType -> EM.Err a
errorLogicOperand op r t =
    badLoc (locOf r) $ "The operand '" ++ (printLim r) ++ "' in a " ++ op ++ " expression should have type bool, instead has type " ++ (show t)

errorOr :: RExp t -> TCType -> EM.Err a
errorOr = errorLogicOperand "OR"

errorAnd :: RExp t -> TCType -> EM.Err a
errorAnd = errorLogicOperand "AND"

errorNot :: RExp t -> TCType -> EM.Err a
errorNot = errorLogicOperand "NOT"



errorBinary :: (Show binop) => binop -> RExp t -> RExp t -> TCType -> TCType -> EM.Err b
errorBinary op r1 r2 t1 t2 =
    badLoc (locOf r1) $ "Operands '" ++ (printLim r1) ++ "' (type: " ++ (show t1) ++ ") and '" ++ (printLim r2) ++ "' (type: " ++ (show t2) ++ ") are not compatible in a " ++ (show op) ++ " expression"

errorArithmetic :: (Show binop) => binop -> RExp t -> RExp t -> TCType -> TCType -> EM.Err b
errorArithmetic op r1 r2 t1 t2 =
    badLoc (locOf r1) $ "Operands '" ++ (printLim r1) ++ "' (type: " ++ (show t1) ++ ") and '" ++ (printLim r2) ++ "' (type: " ++ (show t2) ++ ") are not a subtype of real in a " ++ (show op) ++ " expression"

errorArithOperandInt :: RExp t -> TCType -> EM.Err a
errorArithOperandInt r t =
    badLoc (locOf r) $ "Operand '" ++ (printLim r) ++ "' should have type int, but found " ++ (show t)




errorSignNotNumber :: RExp t -> TCType -> EM.Err a
errorSignNotNumber r t =
    badLoc (locOf r) $ "Signed expression '" ++ (printLim r) ++ "' must be a number, found " ++ (show t)


errorRefToImmutable :: LExp t -> EM.Err a
errorRefToImmutable l =
    badLoc (locOf l) $ "Invalid reference to an immutable expression: '" ++ (printLim l) ++ "' is immutable"

errorArrayEmpty :: Loc -> EM.Err a
errorArrayEmpty loc = badLoc loc "Empty array initializer"

errorArrayElementsCompatibility :: Loc -> EM.Err a
errorArrayElementsCompatibility loc =
    badLoc loc "Types in the array initializer list are not compatible"

errorArrayIndex :: RExp t -> EM.Err a
errorArrayIndex r =
    badLoc (locOf r) $ "Array index '" ++ (printLim r) ++ "' should have type integer in an ARRAY ACCESS"

errorArrayNot :: LExp t -> EM.Err a
errorArrayNot lexp =
    badLoc (locOf lexp) $ "Left expression '" ++ (printLim lexp) ++ "' is not an array in an ARRAY ACCESS"

errorArrayNonIntegerSize :: RExp t -> TCType -> EM.Err a
errorArrayNonIntegerSize rexp t =
    badLoc (locOf rexp) $ "Size of an array must be an integer constant, but found '" ++ (printLim rexp) ++ "' of type " ++ (show t)

errorArrayNonConstantSize :: RExp t -> EM.Err a
errorArrayNonConstantSize rexp =
    badLoc (locOf rexp) $ "Size of an array must be an integer constant, but '" ++ (printLim rexp) ++ "' is not"



errorNotAPointer :: LExp t -> EM.Err a
errorNotAPointer lexp = 
    badLoc (locOf lexp) $ "Trying to dereference '" ++ (printLim lexp) ++ "' which is not a pointer"



errorDoesNotExist :: String -> Ident -> EM.Err a
errorDoesNotExist s (Ident loc id) =
    badLoc loc $ s ++ " '" ++ id ++ "' does not exist at this scope"

errorNameDoesNotExist :: Ident -> EM.Err a
errorNameDoesNotExist = errorDoesNotExist "Name"

errorFunDoesNotExist :: Ident -> EM.Err a
errorFunDoesNotExist = errorDoesNotExist "Function name"

errorConstDoesNotExist :: Ident -> EM.Err a
errorConstDoesNotExist = errorDoesNotExist "Compile-time constant name"

errorNameAlreadyDeclared :: Ident -> Loc -> EM.Err a
errorNameAlreadyDeclared (Ident loc id) whr =
    badLoc loc $ "Name '" ++ id ++ "' already declared at " ++ (show whr)



errorRangeStart :: Loc -> RExp t -> TCType -> EM.Err a
errorRangeStart loc st t =
    badLoc loc $ "Start of range '" ++ (printLim st) ++ "' should be of type int, instead have type " ++ (show t)

errorRangeEnd :: Loc -> RExp t -> TCType -> EM.Err a
errorRangeEnd loc en t =
    badLoc loc $ "End of range '" ++ (printLim en) ++ "' should be of type int, instead have type " ++ (show t)




errorDeclTypeMismatch :: String -> Ident -> TCType -> TCType -> EM.Err a
errorDeclTypeMismatch kind id td tr = 
    badLoc (locOf id) $ "Type mismatch in a " ++ kind ++ " declaration. '" ++ (idName id) ++ "' should have type " ++ (show tr) ++ ", instead has type " ++ (show td)

errorConstTypeMismatch :: Ident -> TCType -> TCType -> EM.Err a
errorConstTypeMismatch = errorDeclTypeMismatch "param"

errorVarTypeMismatch :: Ident -> TCType -> TCType -> EM.Err a
errorVarTypeMismatch = errorDeclTypeMismatch "var"

errorNotConst :: Ident -> RExp t -> EM.Err a
errorNotConst id r =
    badLoc (locOf id) $ "Initializer expression '" ++ (printLim r) ++ "' is not a constant expression"

errorTypeVoid :: String -> Ident -> EM.Err a
errorTypeVoid s (Ident loc name) =
    badLoc loc $ s ++ " '" ++ name ++ "' cannot be of type void"

errorVariableVoid :: Ident -> EM.Err a
errorVariableVoid = errorTypeVoid "Variable"

errorConstantVoid :: Ident -> EM.Err a
errorConstantVoid = errorTypeVoid "Constant"

errorParameterVoid :: Ident -> EM.Err a
errorParameterVoid = errorTypeVoid "Parameter"


errorReturnLoop :: Loc -> EM.Err a
errorReturnLoop loc =
    badLoc loc $ "Cannot 'return' inside a loop"

errorReturnProcedure :: Loc -> TCType -> EM.Err a
errorReturnProcedure loc t =
    badLoc loc $ "Missing expression in a 'return' statement: expected type " ++ (show t)

errorReturnTypeMismatch :: Loc -> TCType -> TCType -> EM.Err a
errorReturnTypeMismatch loc t tr =
    badLoc loc $ "Type mismatch in a 'return' statement: expected type " ++ (show tr) ++ ", found " ++ (show t)

errorReturnIntent :: Loc -> Intent -> EM.Err a
errorReturnIntent loc it =
    badLoc loc $ "Return intent must be either 'in' or 'ref', found '" ++ (printLim it) ++ "'"

errorReturnRef :: RExp t -> EM.Err a
errorReturnRef r =
    badLoc (locOf r) $ "Returned expression '" ++ (printLim r) ++ "' must be a left-expression"

errorReturnMissing :: Ident -> EM.Err a
errorReturnMissing (Ident loc id) =
    badLoc loc $ "Missing return in a function definition: '" ++ id ++ "' is not a total function"

errorMissingAssignRes :: Loc -> String -> String -> EM.Err a
errorMissingAssignRes loc id n =
    badLoc loc $ "Missing assignment to '" ++ n ++ "' passed by 'inout' in the definition of '" ++ id ++ "'"




errorFor :: String -> Loc -> EM.Err a
errorFor key loc =
    badLoc loc $ "Cannot use '" ++ key ++ "' inside of a for statement"

errorOutside :: String -> Loc -> EM.Err a
errorOutside key loc =
    badLoc loc $ "Cannot use '" ++ key ++ "' outside of a (do-)while statement"

errorBreakFor :: Loc -> EM.Err a
errorBreakFor = errorFor "break"

errorBreakOutside :: Loc -> EM.Err a
errorBreakOutside = errorOutside "break"

errorContinueFor :: Loc -> EM.Err a
errorContinueFor = errorFor "continue"

errorContinueOutside :: Loc -> EM.Err a
errorContinueOutside = errorOutside "continue"



errorGuard :: RExp t -> TCType -> EM.Err a
errorGuard r t =
    badLoc (locOf r) $ "Type mismatch in a guard. Expected type bool, found " ++ (show t)




errorAssignType :: LExp TCType -> RExp TCType -> EM.Err a
errorAssignType l r =
    badLoc (locOf l) $ "Type mismatch in an assignment between l-expression '" ++ (printLim l) ++ "' of type " ++ (show $ tctypeOf l) ++ " and r-expression '" ++ (printLim r) ++ "' of type " ++ (show $ tctypeOf r)

errorAssignImmutable :: LExp t -> EM.Err a
errorAssignImmutable l =
    badLoc (locOf l) $ "Cannot modify '" ++ (printLim l) ++ "' because it's immutable"

errorAssignMod :: LExp t -> TCType -> EM.Err a
errorAssignMod l t =
    badLoc (locOf l) $ "Left expression '" ++ (printLim l) ++ "' in a mod assignment should have type int, found " ++ (show t)

errorAssignPow :: RExp t -> TCType -> EM.Err a
errorAssignPow r t =
    badLoc (locOf r) $ "Right expression '" ++ (printLim r) ++ "' in a pow assignment should have type int, found " ++ (show t)

errorAssignNotReal :: RExp t -> TCType -> EM.Err a
errorAssignNotReal r t = 
    badLoc (locOf r) $ "Right expression '" ++ (printLim r) ++ "' should be a number, found " ++ (show t)

errorAssignFunction :: Loc -> EM.Err a
errorAssignFunction loc =
    badLoc loc $ "Functions cannot be on the left of an assignment"




errorCallWrongNumber :: Ident -> Int -> Int -> EM.Err a
errorCallWrongNumber (Ident loc id) la lp=
    badLoc loc $ "Wrong number of parameters in a function call for '" ++ id ++ "': expected " ++ (show lp) ++ ", found " ++ (show la)

errorCallNotAProcedure :: Ident -> TCType -> EM.Err a
errorCallNotAProcedure id t =
    badLoc (locOf id) $ "'" ++ (idName id) ++ "' cannot be used as a statement: '" ++ (idName id) ++ "' is a function with return type " ++ (show t) ++ ", not a procedure"

errorCallNotAFunction :: RExp t -> EM.Err a
errorCallNotAFunction call@(FCall loc id _ _ _) =
    badLoc loc $ "Expression '" ++ (printLim call) ++ "' is a function call, but '" ++ (idName id) ++ "' is a procedure"


errorPassingTypeSub :: RExp t -> TCType -> TCType -> EM.Err a
errorPassingTypeSub r t tp =
    badLoc (locOf r) $ "Type mismatch: type " ++ (show t) ++ " of actual argument '" ++ (printLim r) ++ "' is not a subtype of " ++ (show tp)

errorPassingTypeSuper :: RExp t -> TCType -> TCType -> EM.Err a
errorPassingTypeSuper r t tp =
    badLoc (locOf r) $ "Type mismatch: type " ++ (show t) ++ " of actual argument '" ++ (printLim r) ++ "' is not a supertype of " ++ (show tp)

errorPassingTypeSame :: RExp t -> TCType -> TCType -> EM.Err a
errorPassingTypeSame r t tp =
    badLoc (locOf r) $ "Type mismatch: type " ++ (show t) ++ " of actual argument '" ++ (printLim r) ++ "' is not the same as " ++ (show tp)


errorPassingLExp :: RExp t -> EM.Err a
errorPassingLExp r =
    badLoc (locOf r) $ "Expression '" ++ (printLim r) ++ "' must be a left-expression"

errorPassingImmutable :: Intent -> RExp t -> EM.Err a
errorPassingImmutable it r =
    badLoc (locOf r) $ "Cannot pass '" ++ (printLim r) ++ "' with intent " ++ (printLim it) ++ " because it's immutable"




checkExpError :: (Print b) => (a -> b -> EM.Err c) -> (a -> b -> EM.Err c)
checkExpError f = \a b -> case f a b of
    EM.Ok x     -> return x
    EM.Bad s    -> EM.Bad $ s ++ "\n\tIn the expression '" ++ (printLim b) ++ "'."