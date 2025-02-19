module Evaluator.Strings where

import LispTypes
import Environment
import Evaluator.Operators

import Control.Monad.Except

stringPrimitives :: [(String, [LispVal] -> ThrowsError LispVal)]
stringPrimitives = 
    [("string", stringConstructor), -- String constructors
    ("substring", substring),
    ("string->list", stringToList), -- String conversion
--  ("string->number", stringToNum),
    ("string=?", strBoolBinop (==)), -- String Comparison
    ("string<?", strBoolBinop (<)),
    ("string>?", strBoolBinop (>)),
    ("string<=?", strBoolBinop (<=)),
    ("string>=?", strBoolBinop (>=)),
    ("string-ci=?", ciStrBoolBinop (==)),
    ("string-ci<?", ciStrBoolBinop (<)),
    ("string-ci>?", ciStrBoolBinop (>)),
    ("string-ci<=?", ciStrBoolBinop (<=)),
    ("string-ci>=?", ciStrBoolBinop (>=)), 
    ("string-length", stringLength), -- String procedures
    ("string?", unaryOp stringp), -- String predicates
    ("string-null?", stringNull)]

-- |Type testing functions
stringp :: LispVal -> LispVal
stringp (String _)      = Bool True
stringp _               = Bool False

-- |Create a string from a list of characters
stringConstructor :: [LispVal] -> ThrowsError LispVal
stringConstructor [] = return $ String ""
stringConstructor charl = makestr (String "") charl
    -- Append Char by Char to the newly allocated string
    where
        makestr :: LispVal -> [LispVal] -> ThrowsError LispVal
        makestr (String str) (Character x : xs) = makestr (String (str ++ [x])) xs
        makestr str@(String _) [] = return str 
        makestr str (x : xs) = throwError $ TypeMismatch "char" x

-- |Check if a string is empty
stringNull :: [LispVal] -> ThrowsError LispVal
stringNull [String x] = return $ Bool $ null x
stringNull [x] = throwError $ TypeMismatch "string" x 
stringNull badArglist = throwError $ NumArgs 2 badArglist

-- |Make a substring from start to end
substring :: [LispVal] -> ThrowsError LispVal
substring [String x, Number start, Number end] 
    | start < 0 || start > end || start > toInteger (length x) || end > toInteger (length x) = 
        throwError $ Default "indexes must satisfy 0 <= start <= end (string-length string)"
    | start == end = return $ String ""
    -- Zip indexes to string and filter out the elements not in the range (start, end)  
    | otherwise = return $ String $ map fst $ filter (\(x, i) -> i >= start && i < end) $ zip x [0..]
substring badArglist = throwError $ NumArgs 3 badArglist

-- |Get a length of a string
stringLength :: [LispVal] -> ThrowsError LispVal
stringLength [String x] = return $ Number $ toInteger $ length x
stringLength [x] = throwError $ TypeMismatch "string" x
stringLength badArglist = throwError $ NumArgs 1 badArglist

-- |Convert a String to a List of characters
stringToList :: [LispVal] -> ThrowsError LispVal
stringToList [String x] = return $ List $ map Character x
stringToList [x] = throwError $ TypeMismatch "string" x
stringToList badArglist = throwError $ NumArgs 1 badArglist

-- #TODO parse numbers correctly
-- |Convert a String to a number by reading it
-- stringToNum :: [LispVal] -> ThrowsError LispVal
-- stringToNum [String x] = let parsed = reads x in 
--     if null parsed then throwError $ TypeMismatch "number" $ String x
--     else return $ fst $ head parsed
-- stringToNum [x] = throwError $ TypeMismatch "string" x
-- stringToNum badArglist = throwError $ NumArgs 1 badArglist

