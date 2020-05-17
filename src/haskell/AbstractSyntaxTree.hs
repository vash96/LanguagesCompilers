-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.

{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TemplateHaskell #-}

module AbstractSyntaxTree where

import Control.Lens -- For getters

{-

Ex.

data A = A { _aName :: String, _aAge :: Int }
makeFields ''A

translates into:
varA = A "Pippo" 42
varA^.name --------------------- get field _aName
varA^.age  --------------------- get field _aAge


-}

data Loc 
  = Loc {
    _locLine :: Loc
  , _locColumn :: Int }
  | NoLoc
  deriving (Eq, Ord, Show, Read)
makeFields ''Loc

data Ident = Ident {
    _identName :: String
  , _identLoc :: Loc
} deriving (Eq, Ord, Show, Read)
makeFields ''Ident

data Program = Prog [DList] [FDecl]
  deriving (Eq, Ord, Show, Read)

data FDecl = FDecl {
    _fdeclRtype :: RType
  , _fdeclIdent :: Ident
  , _fdeclParams :: [Param]
  , _fdeclBlock :: Block
  , _fdeclLoc :: Loc
} deriving (Eq, Ord, Show, Read)
makeFields ''FDecl

data Param = Param {
    _paramType :: Type
  , _paramPassby :: PassBy
  , _paramIdent :: Ident
  , _paramLoc :: Loc
} deriving (Eq, Ord, Show, Read)
makeFields ''Param

data PassBy
    = PassVal
    | PassRef
    | PassName
    | PassRes
    | PassValRes
    | PassConst
  deriving (Eq, Ord, Show, Read)

data DList 
    = VList {
        _dlistType :: Type
      , _dlistVdecls :: [VDecl]
      , _dlistLoc :: Loc }
    | CList {
        _dlistCdecls :: [CDecl]
      , _dlistLoc :: Loc }
  deriving (Eq, Ord, Show, Read)
makeFields ''DList

data VDecl
  = VSolo {
    _vdeclIdent :: Ident
  , _vdeclLoc :: Loc }
  | VInit {
    _vdeclIdent :: Ident
  , _vdeclRexp :: RExp
  , _vdeclLoc :: Loc }
  deriving (Eq, Ord, Show, Read)
makeFields ''VDecl

data CDecl = CDecl {
    _cdeclIdent :: Ident
  , _cdeclRexp :: RExp
  , _cdeclLoc :: Loc
} deriving (Eq, Ord, Show, Read)
makeFields ''CDecl

data Type = Type Basic Compound
  deriving (Eq, Ord, Show, Read)

data Compound = Simple | Array Compound RExp | Pointer Compound
  deriving (Eq, Ord, Show, Read)

data Basic = BBool | BChar | BInt | BFloat | BString
  deriving (Eq, Ord, Show, Read)

data RType = RVoid | RBasic Basic | RRef Type
  deriving (Eq, Ord, Show, Read)

data Block = Block {
    _blockDlists :: [DList]
  , _blockStms :: [Stm]
  , _blockLoc :: Loc
} deriving (Eq, Ord, Show, Read)
makeFields ''Block

data Stm
    = StmBlock { _stmBlock :: Block, _stmLoc :: Loc }
    | StmCall { _stmIdent :: Ident, _stmArgs :: [RExp], _stmLoc :: Loc }
    | WriteChar { _stmArg :: RExp, _stmLoc :: Loc }
    | WriteInt { _stmArg :: RExp, _stmLoc :: Loc }
    | WriteFloat { _stmArg :: RExp, _stmLoc :: Loc }
    | WriteString { _stmArg :: RExp, _stmLoc :: Loc }
    | AssignEq { _stmTo :: LExp, _stmFrom :: RExp, _stmLoc :: Loc }
    | AssignAdd { _stmTo :: LExp, _stmFrom :: RExp, _stmLoc :: Loc }
    | AssignSub { _stmTo :: LExp, _stmFrom :: RExp, _stmLoc :: Loc }
    | AssignMul { _stmTo :: LExp, _stmFrom :: RExp, _stmLoc :: Loc }
    | AssignDiv { _stmTo :: LExp, _stmFrom :: RExp, _stmLoc :: Loc }
    | AssignMod { _stmTo :: LExp, _stmFrom :: RExp, _stmLoc :: Loc }
    | StmL { _stmWho :: LExp, _stmLoc :: Loc }
    | If { _stmCond :: RExp, _stmIftrue :: Stm, _stmLoc :: Loc }
    | IfElse { _stmCond :: RExp, _stmIftrue :: Stm, _stmIffalse :: Stm, _stmLoc :: Loc }
    | While { _stmCond :: RExp, _stmIftrue :: Stm, _stmLoc :: Loc }
    | DoWhile { _stmCond :: Stm, _stmIftrue :: RExp, _stmLoc :: Loc }
    | ForUp { _stmIdent :: Ident, _stmStart :: RExp, _stmEnd :: RExp, _stmIftrue :: Stm, _stmLoc :: Loc }
    | ForDown { _stmIdent :: Ident, _stmStart :: RExp, _stmEnd :: RExp, _stmIftrue :: Stm, _stmLoc :: Loc }
    | Return { _stmLoc :: Loc }
    | ReturnE { _stmWhat :: RExp, _stmLoc :: Loc }
    | Break { _stmLoc :: Loc }
    | Continue { _stmLoc :: Loc }
  deriving (Eq, Ord, Show, Read)
makeFields ''Stm

data LExp
    = Deref { _lexpWho :: LExp, _lexpLoc :: Loc }
    | PostInc { _lexpWho :: LExp, _lexpLoc :: Loc }
    | PostDec { _lexpWho :: LExp, _lexpLoc :: Loc }
    | PreInc { _lexpWho :: LExp, _lexpLoc :: Loc }
    | PreDec { _lexpWho :: LExp, _lexpLoc :: Loc }
    | Access { _lexpWho :: LExp, _lexpIndex :: RExp, _lexpLoc :: Loc }
    | Name { _lexpIdent :: Ident, _lexpLoc :: Loc }
  deriving (Eq, Ord, Show, Read)
makeFields ''LExp

data RExp
    = Or { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | And { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Not { _rexpRight :: RExp, _rexpLoc :: Loc }
    | Lt { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Le { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Eq { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Neq { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Geq { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Gt { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Add { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Sub { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Mul { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Div { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Rem { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Pow { _rexpLeft :: RExp, _rexpRight :: RExp, _rexpLoc :: Loc }
    | Plus { _rexpRight :: RExp, _rexpLoc :: Loc }
    | Minus { _rexpRight :: RExp, _rexpLoc :: Loc }
    | Ref { _rexpWho :: LExp, _rexpLoc :: Loc }
    | RLExp { _rexpWho :: LExp, _rexpLoc :: Loc }
    | ArrList { _rexpArr :: [RExp], _rexpLoc :: Loc }
    | FCall { _rexpIdent :: Ident, _rexpArgs :: [RExp], _rexpLoc :: Loc }
    | ReadChar { _rexpLoc :: Loc }
    | ReadInt { _rexpLoc :: Loc }
    | ReadFloat { _rexpLoc :: Loc }
    | ReadString { _rexpLoc :: Loc }
    | LFalse { _rexpLoc :: Loc }
    | LTrue { _rexpLoc :: Loc }
    | LChar { _rexpValue :: Char, _rexpLoc :: Loc }
    | LInt { _rexpValue :: Integer, _rexpLoc :: Loc }
    | LFloat { _rexpValue :: Double, _rexpLoc :: Loc }
    | LString { _rexpValue :: String, _rexpLoc :: Loc }
  deriving (Eq, Ord, Show, Read)
makeFields ''RExp
