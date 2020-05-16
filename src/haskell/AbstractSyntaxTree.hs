-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.

module AbstractSyntaxTree where
  
data Posn a = Posn { pos :: (Int, Int), value :: a }
  deriving (Eq, Ord, Show, Read)

getL :: Posn a -> Int
getL = fst . pos

getC :: Posn a -> Int
getC = snd . pos


newtype Ident = Ident String
  deriving (Eq, Ord, Show, Read)

data Program = Prog [Posn FDecl]
  deriving (Eq, Ord, Show, Read)

data FDecl = FDecl RType (Posn Ident) [Posn Param] Block
  deriving (Eq, Ord, Show, Read)

data Param = Param Type PassBy (Posn Ident)
  deriving (Eq, Ord, Show, Read)

data PassBy = PassVal | PassRef
  deriving (Eq, Ord, Show, Read)

data DList = VList Type [Posn VDecl] | CList [Posn CDecl]
  deriving (Eq, Ord, Show, Read)

data VDecl = VSolo (Posn Ident) | VInit (Posn Ident) (Posn RExp)
  deriving (Eq, Ord, Show, Read)

data CDecl = CDecl (Posn Ident) (Posn RExp)
  deriving (Eq, Ord, Show, Read)

data Type = Type Basic Compound
  deriving (Eq, Ord, Show, Read)

data Compound = Simple | Array Compound RExp | Pointer Compound
  deriving (Eq, Ord, Show, Read)

data Basic = BBool | BChar | BInt | BFloat | BString
  deriving (Eq, Ord, Show, Read)

data RType = RVoid | RBasic Basic | RRef Type
  deriving (Eq, Ord, Show, Read)

data Block = Block [DList] [Posn Stm]
  deriving (Eq, Ord, Show, Read)

data Stm
    = StmBlock (Posn Block)
    | StmCall (Posn Ident) [Posn RExp]
    | PredW PWrite (Posn RExp)
    | Assign (Posn LExp) AssignOp (Posn RExp)
    | StmL (Posn LExp)
    | If (Posn RExp) (Posn Stm)
    | IfElse (Posn RExp) (Posn Stm) (Posn Stm)
    | While (Posn RExp) (Posn Stm)
    | DoWhile (Posn Stm) (Posn RExp)
    | For (Posn Ident) (Posn RExp) Dir (Posn RExp) (Posn Stm)
    | JmpStm (Posn Jump)
  deriving (Eq, Ord, Show, Read)

data Dir = UpTo | DownTo
  deriving (Eq, Ord, Show, Read)

data Jump = Return | ReturnE (Posn RExp) | Break | Continue
  deriving (Eq, Ord, Show, Read)

data LExp
    = Deref (Posn LExp)
    | Post (Posn LExp) IncDecOp
    | Pre IncDecOp (Posn LExp)
    | Access (Posn LExp) (Posn RExp)
    | Name (Posn Ident)
  deriving (Eq, Ord, Show, Read)

data RExp
    = Or (Posn RExp) (Posn RExp)
    | And (Posn RExp) (Posn RExp)
    | Not  (Posn RExp)
    | Comp (Posn RExp) CompOp (Posn RExp)
    | Add (Posn RExp) (Posn RExp)
    | Sub (Posn RExp) (Posn RExp)
    | Mul (Posn RExp) (Posn RExp)
    | Div (Posn RExp) (Posn RExp)
    | Rem (Posn RExp) (Posn RExp)
    | Pow (Posn RExp) (Posn RExp)
    | Sign SignOp (Posn RExp)
    | Ref (Posn LExp)
    | RLExp (Posn LExp)
    | ArrList [Posn RExp]
    | FCall (Posn Ident) [Posn RExp]
    | PredR PRead
    | Lit (Posn Literal)
  deriving (Eq, Ord, Show, Read)

data PRead = ReadChar | ReadInt | ReadFloat | ReadString
  deriving (Eq, Ord, Show, Read)

data PWrite = WriteChar | WriteInt | WriteFloat | WriteString
  deriving (Eq, Ord, Show, Read)

data AssignOp
    = AssignEq
    | AssignAdd
    | AssignSub
    | AssignMul
    | AssignDiv
    | AssignMod
  deriving (Eq, Ord, Show, Read)

data CompOp = Lt | Leq | Eq | Neq | Geq | Gt
  deriving (Eq, Ord, Show, Read)

data IncDecOp = Inc | Dec
  deriving (Eq, Ord, Show, Read)

data SignOp = Pos | Neg
  deriving (Eq, Ord, Show, Read)

data Literal
    = LBool Boolean
    | LChar Char
    | LInt Integer
    | LFloat Double
    | LString String
  deriving (Eq, Ord, Show, Read)

data Boolean = BFalse | BTrue
  deriving (Eq, Ord, Show, Read)

