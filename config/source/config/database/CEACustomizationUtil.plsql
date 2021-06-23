-----------------------------------------------------------------------------
--
--  Logical unit: CEACustomizationUtil
--  Component:    CONFIG
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-- C0436 EntPrageG (START)
PROCEDURE Get_Document_Keys_From_Key_Ref___(
   doc_class_ OUT VARCHAR2,
   doc_no_    OUT VARCHAR2,
   doc_sheet_ OUT VARCHAR,
   doc_rev_   OUT VARCHAR2,
   key_ref_    IN VARCHAR2)
IS
BEGIN
   doc_class_ := Client_SYS.Get_Key_Reference_Value(key_ref_, 'DOC_CLASS');
   doc_no_ := Client_SYS.Get_Key_Reference_Value(key_ref_, 'DOC_NO');
   doc_sheet_ := Client_SYS.Get_Key_Reference_Value(key_ref_, 'DOC_SHEET');
   doc_rev_ := Client_SYS.Get_Key_Reference_Value(key_ref_, 'DOC_REV');   
END Get_Document_Keys_From_Key_Ref___;

FUNCTION Get_Doc_Resp_Person___ (
   key_ref_ IN VARCHAR2) RETURN VARCHAR2
IS
   doc_class_  VARCHAR2(20);
   doc_no_     VARCHAR2(20);
   doc_sheet_  VARCHAR2(20);
   doc_rev_    VARCHAR2(20);  
   resp_per_ VARCHAR2(50);
BEGIN
   Get_Document_Keys_From_Key_Ref___(doc_class_,doc_no_,doc_sheet_,doc_rev_,key_ref_);
   resp_per_:= Doc_Issue_API.Get_Doc_Resp_Sign(doc_class_,doc_no_,doc_sheet_,doc_rev_);
RETURN resp_per_;
END Get_Doc_Resp_Person___;
-- C0436 EntPrageG (END)

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU  NEW METHODS -------------------------------------
