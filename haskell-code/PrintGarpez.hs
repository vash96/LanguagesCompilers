{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for PrintGarpez.
--   Generated by the BNF converter.

module PrintGarpez where

import qualified AbsGarpez
import Data.Char

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else ' ':s)

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print AbsGarpez.Id where
  prt _ (AbsGarpez.Id (_,i)) = doc (showString i)

instance Print AbsGarpez.PBool where
  prt _ (AbsGarpez.PBool (_,i)) = doc (showString i)

instance Print AbsGarpez.PChar where
  prt _ (AbsGarpez.PChar (_,i)) = doc (showString i)

instance Print AbsGarpez.PInt where
  prt _ (AbsGarpez.PInt (_,i)) = doc (showString i)

instance Print AbsGarpez.PFloat where
  prt _ (AbsGarpez.PFloat (_,i)) = doc (showString i)

instance Print AbsGarpez.PString where
  prt _ (AbsGarpez.PString (_,i)) = doc (showString i)

instance Print AbsGarpez.Return where
  prt _ (AbsGarpez.Return (_,i)) = doc (showString i)

instance Print AbsGarpez.Break where
  prt _ (AbsGarpez.Break (_,i)) = doc (showString i)

instance Print AbsGarpez.Continue where
  prt _ (AbsGarpez.Continue (_,i)) = doc (showString i)

instance Print AbsGarpez.RChar where
  prt _ (AbsGarpez.RChar (_,i)) = doc (showString i)

instance Print AbsGarpez.RInt where
  prt _ (AbsGarpez.RInt (_,i)) = doc (showString i)

instance Print AbsGarpez.RFloat where
  prt _ (AbsGarpez.RFloat (_,i)) = doc (showString i)

instance Print AbsGarpez.RString where
  prt _ (AbsGarpez.RString (_,i)) = doc (showString i)

instance Print AbsGarpez.WChar where
  prt _ (AbsGarpez.WChar (_,i)) = doc (showString i)

instance Print AbsGarpez.WInt where
  prt _ (AbsGarpez.WInt (_,i)) = doc (showString i)

instance Print AbsGarpez.WFloat where
  prt _ (AbsGarpez.WFloat (_,i)) = doc (showString i)

instance Print AbsGarpez.WString where
  prt _ (AbsGarpez.WString (_,i)) = doc (showString i)

instance Print AbsGarpez.Program where
  prt i e = case e of
    AbsGarpez.Prog globals -> prPrec i 0 (concatD [prt 0 globals])

instance Print AbsGarpez.Global where
  prt i e = case e of
    AbsGarpez.GlobalDecl declaration -> prPrec i 0 (concatD [prt 0 declaration])
    AbsGarpez.FunDecl function -> prPrec i 0 (concatD [prt 0 function])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [AbsGarpez.Global] where
  prt = prtList

instance Print AbsGarpez.Declaration where
  prt i e = case e of
    AbsGarpez.ConstDecl inititems -> prPrec i 0 (concatD [doc (showString "const"), prt 0 inititems, doc (showString ";")])
    AbsGarpez.VarDecl type_ declitems -> prPrec i 0 (concatD [prt 0 type_, prt 0 declitems, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsGarpez.InitItem where
  prt i e = case e of
    AbsGarpez.InitDecl id rexp -> prPrec i 0 (concatD [prt 0 id, doc (showString "="), prt 0 rexp])
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsGarpez.DeclId where
  prt i e = case e of
    AbsGarpez.DeclOnly id -> prPrec i 0 (concatD [prt 0 id])

instance Print AbsGarpez.DeclItem where
  prt i e = case e of
    AbsGarpez.DeclItemDeclId declid -> prPrec i 0 (concatD [prt 0 declid])
    AbsGarpez.DeclItemInitItem inititem -> prPrec i 0 (concatD [prt 0 inititem])
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [AbsGarpez.DeclItem] where
  prt = prtList

instance Print [AbsGarpez.InitItem] where
  prt = prtList

instance Print AbsGarpez.Function where
  prt i e = case e of
    AbsGarpez.Fun rettype funrest -> prPrec i 0 (concatD [doc (showString "function"), prt 0 rettype, prt 0 funrest])

instance Print AbsGarpez.FunRest where
  prt i e = case e of
    AbsGarpez.FRest id formalparams block -> prPrec i 0 (concatD [prt 0 id, doc (showString "("), prt 0 formalparams, doc (showString ")"), prt 0 block])

instance Print AbsGarpez.FormalParam where
  prt i e = case e of
    AbsGarpez.Param passby type_ id -> prPrec i 0 (concatD [prt 0 passby, prt 0 type_, prt 0 id])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsGarpez.PassBy where
  prt i e = case e of
    AbsGarpez.ValuePass -> prPrec i 0 (concatD [])
    AbsGarpez.RefPass -> prPrec i 0 (concatD [doc (showString "ref")])

instance Print [AbsGarpez.FormalParam] where
  prt = prtList

instance Print AbsGarpez.Block where
  prt i e = case e of
    AbsGarpez.Blk declarations statements -> prPrec i 0 (concatD [doc (showString "{"), prt 0 declarations, prt 0 statements, doc (showString "}")])

instance Print [AbsGarpez.Declaration] where
  prt = prtList

instance Print [AbsGarpez.Statement] where
  prt = prtList

instance Print AbsGarpez.Statement where
  prt i e = case e of
    AbsGarpez.BlkStm block -> prPrec i 0 (concatD [prt 0 block])
    AbsGarpez.CallStm id rexps -> prPrec i 0 (concatD [prt 0 id, doc (showString "("), prt 0 rexps, doc (showString ")"), doc (showString ";")])
    AbsGarpez.AssignStm lexp assignmentop rexp -> prPrec i 0 (concatD [prt 0 lexp, prt 0 assignmentop, prt 0 rexp, doc (showString ";")])
    AbsGarpez.LExpStm lexp -> prPrec i 0 (concatD [prt 0 lexp, doc (showString ";")])
    AbsGarpez.CondStm conditional -> prPrec i 0 (concatD [prt 0 conditional])
    AbsGarpez.LoopStm loop -> prPrec i 0 (concatD [prt 0 loop])
    AbsGarpez.JmpStm jump -> prPrec i 0 (concatD [prt 0 jump, doc (showString ";")])
    AbsGarpez.WriteStm wpredefined rexp -> prPrec i 0 (concatD [prt 0 wpredefined, doc (showString "("), prt 0 rexp, doc (showString ")"), doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsGarpez.Conditional where
  prt i e = case e of
    AbsGarpez.ConditionalIf if_ -> prPrec i 0 (concatD [prt 0 if_])

instance Print AbsGarpez.Loop where
  prt i e = case e of
    AbsGarpez.LoopWhile while -> prPrec i 0 (concatD [prt 0 while])
    AbsGarpez.LoopDoWhile dowhile -> prPrec i 0 (concatD [prt 0 dowhile])
    AbsGarpez.LoopFor for -> prPrec i 0 (concatD [prt 0 for])

instance Print AbsGarpez.Jump where
  prt i e = case e of
    AbsGarpez.JumpReturn return -> prPrec i 0 (concatD [prt 0 return])
    AbsGarpez.Jump1 return rexp -> prPrec i 0 (concatD [prt 0 return, prt 0 rexp])
    AbsGarpez.JumpBreak break -> prPrec i 0 (concatD [prt 0 break])
    AbsGarpez.JumpContinue continue -> prPrec i 0 (concatD [prt 0 continue])

instance Print AbsGarpez.WPredefined where
  prt i e = case e of
    AbsGarpez.WPredefinedWChar wchar -> prPrec i 0 (concatD [prt 0 wchar])
    AbsGarpez.WPredefinedWInt wint -> prPrec i 0 (concatD [prt 0 wint])
    AbsGarpez.WPredefinedWFloat wfloat -> prPrec i 0 (concatD [prt 0 wfloat])
    AbsGarpez.WPredefinedWString wstring -> prPrec i 0 (concatD [prt 0 wstring])

instance Print AbsGarpez.If where
  prt i e = case e of
    AbsGarpez.IfCond rexp block restif -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 rexp, doc (showString ")"), prt 0 block, prt 0 restif])

instance Print AbsGarpez.RestIf where
  prt i e = case e of
    AbsGarpez.RestIf_ -> prPrec i 0 (concatD [])
    AbsGarpez.RestIf1 if_ -> prPrec i 0 (concatD [doc (showString "else"), prt 0 if_])
    AbsGarpez.RestIf2 block -> prPrec i 0 (concatD [doc (showString "else"), prt 0 block])

instance Print AbsGarpez.While where
  prt i e = case e of
    AbsGarpez.WhileLoop rexp block -> prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 rexp, doc (showString ")"), prt 0 block])

instance Print AbsGarpez.DoWhile where
  prt i e = case e of
    AbsGarpez.DoWhileLoop block rexp -> prPrec i 0 (concatD [doc (showString "do"), prt 0 block, doc (showString "while"), doc (showString "("), prt 0 rexp, doc (showString ")"), doc (showString ";")])

instance Print AbsGarpez.For where
  prt i e = case e of
    AbsGarpez.ForLoop declaration rexp1 rexp2 block -> prPrec i 0 (concatD [doc (showString "for"), doc (showString "("), prt 0 declaration, doc (showString ";"), prt 0 rexp1, doc (showString ";"), prt 0 rexp2, doc (showString ")"), prt 0 block])

instance Print AbsGarpez.LExp where
  prt i e = case e of
    AbsGarpez.Dereference lexp -> prPrec i 0 (concatD [doc (showString "*"), prt 1 lexp])
    AbsGarpez.Post lexp incdecop -> prPrec i 1 (concatD [prt 2 lexp, prt 0 incdecop])
    AbsGarpez.Pre incdecop lexp -> prPrec i 2 (concatD [prt 0 incdecop, prt 3 lexp])
    AbsGarpez.ArrayAccess lexp rexp -> prPrec i 3 (concatD [prt 4 lexp, doc (showString "["), prt 0 rexp, doc (showString "]")])
    AbsGarpez.IdExp id -> prPrec i 4 (concatD [prt 0 id])

instance Print AbsGarpez.RExp where
  prt i e = case e of
    AbsGarpez.LogicalOr rexp1 rexp2 -> prPrec i 0 (concatD [prt 0 rexp1, doc (showString "||"), prt 1 rexp2])
    AbsGarpez.LogicalAnd rexp1 rexp2 -> prPrec i 1 (concatD [prt 1 rexp1, doc (showString "&&"), prt 2 rexp2])
    AbsGarpez.LogicalNot rexp -> prPrec i 2 (concatD [doc (showString "!"), prt 3 rexp])
    AbsGarpez.Comparison rexp1 comparisonop rexp2 -> prPrec i 3 (concatD [prt 3 rexp1, prt 0 comparisonop, prt 4 rexp2])
    AbsGarpez.Sum rexp1 rexp2 -> prPrec i 4 (concatD [prt 4 rexp1, doc (showString "+"), prt 5 rexp2])
    AbsGarpez.Sub rexp1 rexp2 -> prPrec i 4 (concatD [prt 4 rexp1, doc (showString "-"), prt 5 rexp2])
    AbsGarpez.Mul rexp1 rexp2 -> prPrec i 5 (concatD [prt 5 rexp1, doc (showString "*"), prt 6 rexp2])
    AbsGarpez.Div rexp1 rexp2 -> prPrec i 5 (concatD [prt 5 rexp1, doc (showString "/"), prt 6 rexp2])
    AbsGarpez.Mod rexp1 rexp2 -> prPrec i 5 (concatD [prt 5 rexp1, doc (showString "%"), prt 6 rexp2])
    AbsGarpez.Pow rexp1 rexp2 -> prPrec i 6 (concatD [prt 7 rexp1, doc (showString "^"), prt 6 rexp2])
    AbsGarpez.Sign signop rexp -> prPrec i 7 (concatD [prt 0 signop, prt 8 rexp])
    AbsGarpez.Reference lexp -> prPrec i 7 (concatD [doc (showString "&"), prt 0 lexp])
    AbsGarpez.LRExp lexp -> prPrec i 8 (concatD [prt 0 lexp])
    AbsGarpez.CallExp id rexps -> prPrec i 9 (concatD [prt 0 id, doc (showString "("), prt 0 rexps, doc (showString ")")])
    AbsGarpez.ReadExp rpredefined -> prPrec i 9 (concatD [prt 0 rpredefined, doc (showString "("), doc (showString ")")])
    AbsGarpez.Lit literal -> prPrec i 10 (concatD [prt 0 literal])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsGarpez.Literal where
  prt i e = case e of
    AbsGarpez.LiteralPBool pbool -> prPrec i 0 (concatD [prt 0 pbool])
    AbsGarpez.LiteralPChar pchar -> prPrec i 0 (concatD [prt 0 pchar])
    AbsGarpez.LiteralPInt pint -> prPrec i 0 (concatD [prt 0 pint])
    AbsGarpez.LiteralPFloat pfloat -> prPrec i 0 (concatD [prt 0 pfloat])
    AbsGarpez.LiteralPString pstring -> prPrec i 0 (concatD [prt 0 pstring])

instance Print AbsGarpez.RPredefined where
  prt i e = case e of
    AbsGarpez.RPredefinedRChar rchar -> prPrec i 0 (concatD [prt 0 rchar])
    AbsGarpez.RPredefinedRInt rint -> prPrec i 0 (concatD [prt 0 rint])
    AbsGarpez.RPredefinedRFloat rfloat -> prPrec i 0 (concatD [prt 0 rfloat])
    AbsGarpez.RPredefinedRString rstring -> prPrec i 0 (concatD [prt 0 rstring])

instance Print [AbsGarpez.RExp] where
  prt = prtList

instance Print AbsGarpez.Type where
  prt i e = case e of
    AbsGarpez.SType simpletype -> prPrec i 0 (concatD [prt 0 simpletype])
    AbsGarpez.AType type_ pint -> prPrec i 0 (concatD [prt 0 type_, doc (showString "["), prt 0 pint, doc (showString "]")])
    AbsGarpez.PType type_ -> prPrec i 0 (concatD [prt 0 type_, doc (showString "*")])

instance Print AbsGarpez.RetType where
  prt i e = case e of
    AbsGarpez.SRType simpletype -> prPrec i 0 (concatD [prt 0 simpletype])
    AbsGarpez.RRType type_ -> prPrec i 0 (concatD [prt 0 type_, doc (showString "*")])

instance Print AbsGarpez.SimpleType where
  prt i e = case e of
    AbsGarpez.SimpleType_bool -> prPrec i 0 (concatD [doc (showString "bool")])
    AbsGarpez.SimpleType_char -> prPrec i 0 (concatD [doc (showString "char")])
    AbsGarpez.SimpleType_int -> prPrec i 0 (concatD [doc (showString "int")])
    AbsGarpez.SimpleType_float -> prPrec i 0 (concatD [doc (showString "float")])
    AbsGarpez.SimpleType_string -> prPrec i 0 (concatD [doc (showString "string")])
    AbsGarpez.SimpleType_void -> prPrec i 0 (concatD [doc (showString "void")])

instance Print AbsGarpez.AssignmentOp where
  prt i e = case e of
    AbsGarpez.AssignmentOp1 -> prPrec i 0 (concatD [doc (showString "=")])
    AbsGarpez.AssignmentOp2 -> prPrec i 0 (concatD [doc (showString "+=")])
    AbsGarpez.AssignmentOp3 -> prPrec i 0 (concatD [doc (showString "-=")])
    AbsGarpez.AssignmentOp4 -> prPrec i 0 (concatD [doc (showString "*=")])
    AbsGarpez.AssignmentOp5 -> prPrec i 0 (concatD [doc (showString "/=")])
    AbsGarpez.AssignmentOp6 -> prPrec i 0 (concatD [doc (showString "%=")])
    AbsGarpez.AssignmentOp7 -> prPrec i 0 (concatD [doc (showString "^=")])
    AbsGarpez.AssignmentOp8 -> prPrec i 0 (concatD [doc (showString "&=")])
    AbsGarpez.AssignmentOp9 -> prPrec i 0 (concatD [doc (showString "|=")])

instance Print AbsGarpez.ComparisonOp where
  prt i e = case e of
    AbsGarpez.ComparisonOp1 -> prPrec i 0 (concatD [doc (showString "<")])
    AbsGarpez.ComparisonOp2 -> prPrec i 0 (concatD [doc (showString "<=")])
    AbsGarpez.ComparisonOp3 -> prPrec i 0 (concatD [doc (showString "==")])
    AbsGarpez.ComparisonOp4 -> prPrec i 0 (concatD [doc (showString "!=")])
    AbsGarpez.ComparisonOp5 -> prPrec i 0 (concatD [doc (showString ">=")])
    AbsGarpez.ComparisonOp6 -> prPrec i 0 (concatD [doc (showString ">")])

instance Print AbsGarpez.IncDecOp where
  prt i e = case e of
    AbsGarpez.IncDecOp1 -> prPrec i 0 (concatD [doc (showString "++")])
    AbsGarpez.IncDecOp2 -> prPrec i 0 (concatD [doc (showString "--")])

instance Print AbsGarpez.SignOp where
  prt i e = case e of
    AbsGarpez.SignOp1 -> prPrec i 0 (concatD [doc (showString "+")])
    AbsGarpez.SignOp2 -> prPrec i 0 (concatD [doc (showString "-")])

