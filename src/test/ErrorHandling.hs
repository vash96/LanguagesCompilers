module ErrorHandling where

import qualified ErrM as EM
import AbsChapel
import TCType
import Locatable
import PrintChapel


badLoc :: Loc -> String -> EM.Err a
badLoc loc reason = EM.Bad $ (show loc) ++ ": Error! " ++ reason ++ "."



errorLogicOperand :: String -> RExp -> TCType -> EM.Err a
errorLogicOperand op r t =
    badLoc (locOf r) $ "The operand " ++ (printTree r) ++ " in a " ++ op ++ " expression should have type bool, instead has type " ++ (show t)

errorOr :: RExp -> TCType -> EM.Err a
errorOr = errorLogicOperand "OR"

errorAnd :: RExp -> TCType -> EM.Err a
errorAnd = errorLogicOperand "AND"

errorNot :: RExp -> TCType -> EM.Err a
errorNot = errorLogicOperand "NOT"



errorBinary :: (Show a) => a -> RExp -> RExp -> TCType -> TCType -> EM.Err b
errorBinary op r1 r2 t1 t2 =
    badLoc (locOf r1) $ "Operands " ++ (printTree r1) ++ " (type: " ++ (show t1) ++ ") and " ++ (printTree r2) ++ " (type: " ++ (show t2) ++ ") are not compatible in a " ++ (show op) ++ " expression"



errorArrayEmpty :: Loc -> EM.Err a
errorArrayEmpty loc = badLoc loc "Empty array initializer"

errorArrayElementsCompatibility :: Loc -> EM.Err a
errorArrayElementsCompatibility loc =
    badLoc loc "Types in the array initializer list are not compatible"

errorArrayIndex :: RExp -> EM.Err a
errorArrayIndex r =
    badLoc (locOf r) $ "Array index " ++ (printTree r) ++ " should have type integer in an ARRAY ACCESS"

errorArrayNot :: LExp -> EM.Err a
errorArrayNot lexp =
    badLoc (locOf lexp) $ "Left expression " ++ (printTree lexp) ++ " is not an array in an ARRAY ACCESS"



errorNotAPointer :: LExp -> EM.Err a
errorNotAPointer lexp = 
    badLoc (locOf lexp) $ "Trying to dereference " ++ (printTree lexp) ++ " which is not a pointer"




errorNameDoesNotExist :: Ident -> EM.Err a
errorNameDoesNotExist (Ident loc id) =
    badLoc loc $ "Name '" ++ id ++ "' does not exist at this scope"

errorNameAlreadyDeclared :: Ident -> Loc -> EM.Err a
errorNameAlreadyDeclared (Ident loc id) whr =
    badLoc loc $ "Name '" ++ id ++ "' already declared at (" ++ (show whr) ++ ")"



errorRangeStart :: Loc -> RExp -> TCType -> EM.Err a
errorRangeStart loc st t =
    badLoc loc $ "Start of range '" ++ (printTree st) ++ "' should be of type int, instead have type " ++ (show t)

errorRangeEnd :: Loc -> RExp -> TCType -> EM.Err a
errorRangeEnd loc en t =
    badLoc loc $ "End of range '" ++ (printTree en) ++ "' should be of type int, instead have type " ++ (show t)




errorDeclTypeMismatch :: String -> Ident -> TCType -> TCType -> EM.Err a
errorDeclTypeMismatch kind id td tr = 
    badLoc (locOf id) $ "Type mismatch in a " ++ kind ++ " DECLARATION. '" ++ (idName id) ++ "' should have type " ++ (show tr) ++ ", instead has type " ++ (show td)

errorConstTypeMismatch :: Ident -> TCType -> TCType -> EM.Err a
errorConstTypeMismatch = errorDeclTypeMismatch "CONST"

errorVarTypeMismatch :: Ident -> TCType -> TCType -> EM.Err a
errorVarTypeMismatch = errorDeclTypeMismatch "VAR"

errorNotConst :: Ident -> RExp -> EM.Err a
errorNotConst id r =
    badLoc (locOf id) $ "Initializer expression '" ++ (printTree r) ++ "' is not a constant expression"



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
    badLoc loc $ "Return intent must be either 'in' or 'ref', found '" ++ (printTree it) ++ "'"




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



checkExpError :: (Print b) => (a -> b -> EM.Err c) -> (a -> b -> EM.Err c)
checkExpError f = \a b -> case f a b of
    EM.Ok x     -> return x
    EM.Bad s    -> EM.Bad $ s ++ "\n\tIn the expression '" ++ (printTree b) ++ "'."