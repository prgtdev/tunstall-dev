-----------------------------------------------------------------------------
--
--  Logical unit: CPGCustomizationUtil
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

--C0380 EntPrageG (START)
CURSOR get_material_req_lines
    IS
      SELECT Maint_Material_Requisition_API.Get_Contract(maint_material_order_no) contract,
             Sc_Service_Contract_API.Get_Contract_Type(Active_Separate_API.Get_Contract_Id(wo_no)) contract_type,
             wo_no,
             task_seq,
             maint_material_order_no,
             line_item_no,
             part_no,
             spare_contract,
             qty
        FROM maint_material_re155500812_cfv --maint_material_req_line_uiv
       WHERE cf$_capitalised_db = 'TRUE'
         AND qty > 0;

CURSOR get_inventory_transaction_history_line (wo_no_ NUMBER,maint_material_order_no_ NUMBER,contract_ VARCHAR2,part_no_ VARCHAR2) 
    IS
      SELECT source_ref2 task_seq,
             part_no,
             serial_no,
             Inventory_Part_API.Get_Description(contract,part_no) part_desc,
             contract,
             Site_API.Get_Company(contract) company,
             date_created,
             condition_code
        FROM inventory_transaction_hist t
        WHERE source_ref1 = wo_no_
          AND source_ref3 = maint_material_order_no_
          AND contract = contract_
          AND part_no = part_no_
          AND date_created > (SYSDATE - 1)
          AND serial_no != '*';
--C0380 EntPrageG (START)       

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

--C0360 EntPrageG (START)
   PROCEDURE Add_To_Message___(
      msg_        IN OUT VARCHAR2,
      text_           IN VARCHAR2,
      concat_str_     IN VARCHAR2 DEFAULT ' ',
      new_line_       IN BOOLEAN DEFAULT FALSE)
   IS
   BEGIN
      IF new_line_ THEN
         msg_ := msg_ ||CHR(10)||CHR(13); 
      END IF;
      msg_ := msg_ || concat_str_ || text_;
   END Add_To_Message___;
   
   PROCEDURE Log_Info___(
      message_ IN VARCHAR2)
   IS
   BEGIN
      dbms_output.Put_Line(message_);
      Transaction_SYS.Log_Status_Info(message_,'INFO');
   END Log_Info___;
   
   PROCEDURE Log_Progress___(
      message_ IN VARCHAR2)
   IS
   BEGIN
      dbms_output.Put_Line(message_);
      Transaction_SYS.Log_Progress_Info(message_);
   END Log_Progress___;
   
   
   PROCEDURE Log_Warning___(
      message_ IN VARCHAR2)
   IS
   BEGIN
      dbms_output.Put_Line(message_);
      Transaction_SYS.Log_Status_Info(message_);
   END Log_Warning___;
   
   PROCEDURE Log_error___(
      message_ IN VARCHAR2)
   IS
      appl_error_ EXCEPTION;
   BEGIN
      dbms_output.Put_Line(message_);
      Transaction_sys.Log_Error__(Dbms_Random.Random,message_);
      RAISE appl_error_;
   EXCEPTION
      WHEN appl_error_ THEN
         raise_application_error(-20001,message_); 
   END Log_error___;
      
   FUNCTION Fa_Contract___(
      contract_type_ IN VARCHAR2) RETURN BOOLEAN
   IS
      fa_contract_ VARCHAR2(10);
   BEGIN
      SELECT cf$_fa_contract_db
        INTO fa_contract_
        FROM sc_contract_type_cfv
       WHERE contract_type = contract_type_
         AND cf$_fa_contract_db = 'TRUE';
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;  
   END Fa_Contract___;
   
   FUNCTION Convert_To_Fa___(
      contract_ IN VARCHAR2,
      part_no_  IN VARCHAR2) RETURN BOOLEAN
   IS
      convert_to_fa_ VARCHAR2(10);
   BEGIN      
      SELECT cf$_convert_to_fa_db
        INTO convert_to_fa_
        FROM inventory_part_cfv
       WHERE contract = contract_
         AND part_no = part_no_
         AND cf$_convert_to_fa_db = 'TRUE';
      RETURN TRUE; 
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END Convert_To_Fa___;
   
FUNCTION Fixed_Asset_Object_Exist___(
   object_id_ OUT VARCHAR2,
   part_no_    IN VARCHAR2,
   serial_no_  IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    SELECT object_id       
      INTO object_id_
      FROM fa_object t         
     WHERE object_id IN (SELECT object_id
                           FROM fa_object_property t
                          WHERE t.property_code = 'SERIAL'
                            AND t.value_string = serial_no_
                            AND object_id = t.object_id)
       AND object_id IN (SELECT object_id
                           FROM fa_object_property t
                          WHERE t.property_code = 'PART'
                            AND t.value_string = part_no_
                            AND object_id = t.object_id)
       AND state = 'Active'
    FETCH FIRST ROW ONLY;
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
   WHEN TOO_MANY_ROWS THEN -- TO-DO: Log Error
      RAISE;
   WHEN OTHERS THEN
      RAISE; -- TO-DO: Log Error
END Fixed_Asset_Object_Exist___;
   
PROCEDURE Get_Preposting_Data___(
      code_b_            OUT VARCHAR2,
      code_c_            OUT VARCHAR2,
      code_d_            OUT VARCHAR2,
      code_e_            OUT VARCHAR2, 
      code_f_            OUT VARCHAR2,
      code_g_            OUT VARCHAR2,
      code_h_            OUT VARCHAR2,
      code_j_            OUT VARCHAR2,
      pre_accounting_id_  IN VARCHAR2)
   IS
   BEGIN
      SELECT codeno_b, 
             codeno_c, 
             codeno_d, 
             codeno_e, 
             codeno_f, 
             codeno_g, 
             codeno_h, 
             codeno_j
        INTO code_b_,code_c_,code_d_,code_e_,code_f_,code_g_,code_h_,code_j_
        FROM pre_accounting 
       WHERE pre_accounting_id = pre_accounting_id_;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;      
   END Get_Preposting_Data___;
      
FUNCTION Contract_Has_Changed___(
   company_   IN VARCHAR2,
   object_id_ IN VARCHAR2,
   task_seq_  IN VARCHAR2) RETURN BOOLEAN
IS
   pre_accounting_id_ NUMBER;
   wt_code_f_ VARCHAR2(10); -- work task contract
   fa_code_f_ VARCHAR2(10); -- object contract
BEGIN
   pre_accounting_id_ := Jt_Task_API.Get_Pre_Accounting_Id(task_seq_);
   wt_code_f_ :=Pre_Accounting_API.Get_Codeno_F(pre_accounting_id_); 
   fa_code_f_ := Fa_Object_API.Get_Code_F(company_,object_id_); 
   IF wt_code_f_ != fa_code_f_ THEN
      RETURN TRUE;
   END IF;
   RETURN FALSE;
END Contract_Has_Changed___;

PROCEDURE Create_Property___ (
   company_       IN VARCHAR2,
   object_id_     IN VARCHAR2,
   property_code_ IN VARCHAR2,
   value_string_  IN VARCHAR2 DEFAULT NULL,
   value_number_  IN NUMBER DEFAULT NULL,
   value_date_    IN DATE DEFAULT NULL)
IS
   info_ VARCHAR2(4000);
   objid_ VARCHAR2(50);
   objversion_ VARCHAR2(30);
   attr_ VARCHAR2(32000);

   FUNCTION Get_Attr___ RETURN VARCHAR2
   IS
      attr_ VARCHAR2(32000);
   BEGIN
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr('OBJECT_ID', object_id_, attr_);
      Client_SYS.Add_To_Attr('PROPERTY_CODE', property_code_, attr_);
      Client_SYS.Add_To_Attr('VALUE_STRING', value_string_, attr_);
      Client_SYS.Add_To_Attr('VALUE_NUMBER', value_number_, attr_);
      Client_SYS.Add_To_Attr('VALUE_DATE', value_date_, attr_);
      RETURN attr_;
   END Get_Attr___;
BEGIN
   attr_ := Get_Attr___;  
   Fa_Object_Property_API.New__(info_,objid_,objversion_,attr_,'DO');
END Create_Property___;

PROCEDURE Update_Property___(
   objid_         IN VARCHAR2,
   obj_version_   IN VARCHAR2,
   value_string_  IN VARCHAR2 DEFAULT NULL,
   value_number_  IN NUMBER DEFAULT NULL,
   value_date_    IN DATE DEFAULT NULL)
IS
   info_ VARCHAR2(4000);      
   attr_ VARCHAR2(32000);
   objversion_ VARCHAR2(30);

   FUNCTION Get_Attr___ RETURN VARCHAR2
   IS
      attr_ VARCHAR2(32000);
   BEGIN
      Client_SYS.Clear_Attr(attr_);        
      Client_SYS.Add_To_Attr('VALUE_STRING', value_string_, attr_);
      Client_SYS.Add_To_Attr('VALUE_NUMBER', value_number_, attr_);
      Client_SYS.Add_To_Attr('VALUE_DATE', value_date_, attr_);
      RETURN attr_;
   END Get_Attr___;   
BEGIN
   objversion_ := obj_version_;
   attr_ := Get_Attr___;  
   dbms_output.put_line(attr_);
   dbms_output.put_line(objid_);
   dbms_output.put_line(objversion_);
   Fa_Object_Property_API.Modify__(info_,objid_,objversion_,attr_,'DO');
END Update_Property___;

FUNCTION Property_Exists___(
   objid_               OUT VARCHAR2,
   objversion_          OUT VARCHAR2,
   property_val_string_ OUT VARCHAR2,
   property_val_number_ OUT NUMBER,
   property_val_date_   OUT DATE,
   company_              IN VARCHAR2,
   object_id_            IN VARCHAR2,   
   property_code_        IN VARCHAR2) RETURN BOOLEAN
IS      
BEGIN
   SELECT DISTINCT objid,
          objversion,
          value_string,
          value_number,
          value_date
     INTO objid_,
          objversion_,
          property_val_string_,
          property_val_number_,
          property_val_date_
     FROM fa_object_property
    WHERE company = company_
      AND object_id = object_id_
      AND property_code = property_code_;
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;         
END Property_Exists___;

PROCEDURE Create_Or_Update_Property___(
   company_       IN VARCHAR2,
   object_id_     IN VARCHAR2,
   property_code_ IN VARCHAR2,
   value_string_  IN VARCHAR2 DEFAULT NULL,
   value_date_    IN VARCHAR2 DEFAULT NULL,
   value_number_  IN VARCHAR2 DEFAULT NULL)
IS
   objid_ VARCHAR2(50);
   objversion_ VARCHAR2(50);

   property_val_string_ VARCHAR2(100);
   property_val_number_ NUMBER;
   property_val_date_ DATE;
   prev_condition_code_ VARCHAR2(20);

   property_exists_ BOOLEAN := FALSE;   
   val_string_ VARCHAR2(100) := value_string_;
BEGIN

   property_exists_ :=  Property_Exists___(objid_,
                                           objversion_,
                                           property_val_string_,
                                           property_val_number_,
                                           property_val_date_,
                                           company_,
                                           object_id_,                                           
                                           property_code_);
   prev_condition_code_ := property_val_string_;                                        
   CASE property_code_      
      WHEN 'PREV_COND_CODE' THEN
         property_exists_ := Property_Exists___(objid_,
                                                objversion_,
                                                property_val_string_,
                                                property_val_number_,
                                                property_val_date_,
                                                company_,
                                                object_id_,        
                                                'CONDITION_CODE');           
         val_string_ := property_val_string_;
      ELSE
         NULL;
   END CASE;
   IF property_exists_ THEN
      Update_Property___(objid_,objversion_,val_string_,value_number_,value_date_);
   ELSE
      Create_Property___(company_,object_id_,property_code_,value_string_,value_number_,value_date_);
   END IF;   
END Create_Or_Update_Property___;

PROCEDURE Scrap_Fa_Object___ (
      company_         IN VARCHAR2,
      object_id_       IN VARCHAR2,
      disposal_reason_ IN VARCHAR2)
   IS
      attr_ VARCHAR2(32000);
      info_ VARCHAR2(32000);
      objid_ VARCHAR2(30);
      objversion_  VARCHAR2(20);
      
      retroactive_date_ DATE;
      event_date_ DATE;
      depreciation_date_ DATE;
      voucher_date_ DATE;
      voucher_type_ VARCHAR2(10) := 'A';
      user_group_ VARCHAR2(10);      
      
      object_rec_ Fa_Object_API.Public_Rec;
      
      FUNCTION Get_Attr___ RETURN VARCHAR2
      IS
         attr_ VARCHAR2(32000); 
      BEGIN
         Client_SYS.Clear_Attr(attr_);        
         Client_SYS.Add_To_Attr('RETROACTIVE_DATE', retroactive_date_, attr_);
         Client_SYS.Add_To_Attr('EVENT_DATE', event_date_, attr_);
         Client_SYS.Add_To_Attr('DEPRECIATION_DATE', depreciation_date_, attr_);
         Client_SYS.Add_To_Attr('VOUCHER_DATE', voucher_date_, attr_);
         Client_SYS.Add_To_Attr('VOUCHER_TYPE', voucher_type_, attr_);
         Client_SYS.Add_To_Attr('USER_GROUP', user_group_, attr_);
         Client_SYS.Add_To_Attr('DISPOSAL_REASON', disposal_reason_, attr_);
         RETURN attr_;   
      END Get_Attr___;
   BEGIN
      Fa_Object_API.Get_Sale_Scrap_Depr_Date__ (depreciation_date_,company_,object_id_);
      Fa_Object_API.Get_Scrap_Object_Info__(event_date_,voucher_date_,voucher_type_,user_group_,company_,object_id_);
      retroactive_date_:= event_date_;
      
      attr_:= Get_Attr___;
      dbms_output.put_line(attr_);
      object_rec_ := Fa_Object_API.Get(company_,object_id_);
      objid_ := object_rec_."rowid";
      objversion_ := TO_CHAR(object_rec_.rowversion,'YYYYMMDDHH24MISS');
      
      Fa_Object_API.Scrap__(info_,objid_,objversion_,attr_,'DO');
   END Scrap_Fa_Object___;
   
   PROCEDURE Update_Fixed_Asset_Object___(
      company_   IN VARCHAR2,
      object_id_ IN VARCHAR2,
      task_seq_  IN NUMBER)
   IS
      info_ VARCHAR2(4000);
      objid_ VARCHAR2(50);
      objversion_ VARCHAR2(30);

      pre_accounting_id_ NUMBER;
      attr_ VARCHAR2(32000);
      code_b_ VARCHAR2(20);
      code_c_ VARCHAR2(20);
      code_d_ VARCHAR2(20);
      code_e_ VARCHAR2(20);
      code_f_ VARCHAR2(20);
      code_g_ VARCHAR2(20);
      code_h_ VARCHAR2(20);
      code_j_ VARCHAR2(20);

      object_rec_ Fa_Object_API.Public_Rec;

      FUNCTION Get_Attr___ RETURN VARCHAR2
      IS
         attr_ VARCHAR2(32000);
      BEGIN
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('CODE_B', code_b_, attr_ );
         Client_SYS.Add_To_Attr('CODE_C', code_c_, attr_ );
         Client_SYS.Add_To_Attr('CODE_D', code_d_, attr_ );
         Client_SYS.Add_To_Attr('CODE_E', code_e_, attr_ );
         Client_SYS.Add_To_Attr('CODE_F', code_f_, attr_ );
         Client_SYS.Add_To_Attr('CODE_G', code_g_, attr_ );
         Client_SYS.Add_To_Attr('CODE_H', code_h_, attr_ );
         Client_SYS.Add_To_Attr('CODE_I', '', attr_ );
         Client_SYS.Add_To_Attr('CODE_J', code_j_, attr_ );
         RETURN attr_;
      END Get_Attr___; 
   BEGIN
      object_rec_ := Fa_Object_API.Get(company_,object_id_);
      objid_:= object_rec_."rowid";
      objversion_ := TO_CHAR(object_rec_.rowversion,'YYYYMMDDHH24MISS');
      pre_accounting_id_ := Jt_Task_API.Get_Pre_Accounting_Id(task_seq_);      
      Get_Preposting_Data___(code_b_,code_c_,code_d_,code_e_,code_f_,code_g_,code_h_,code_j_,pre_accounting_id_);
      attr_ := Get_Attr___;
      Fa_Object_API.Modify__(info_,objid_,objversion_,attr_,'DO');
   END Update_Fixed_Asset_Object___;
   
   PROCEDURE Update_Properties___(
      object_id_        IN VARCHAR2,
      company_          IN VARCHAR2,
      contract_         IN VARCHAR2,
      wo_no_            IN NUMBER,
      part_no_          IN VARCHAR2, 
      date_created_     IN DATE,
      condition_code_   IN VARCHAR2,
      deinstall_date_   IN DATE)
   IS     
      contract_id_ VARCHAR2(20);
      customer_no_ VARCHAR2(20);
      accounting_year_ NUMBER;
      accounting_period_ NUMBER;
      acc_period_desc_ VARCHAR2(50);
      deins_acc_period_desc_ VARCHAR2(50);
      part_desc_ VARCHAR2(100);
      
   BEGIN
      contract_id_ := Active_Separate_API.Get_Contract_Id(wo_no_);
      customer_no_ := Active_Separate_API.Get_Customer_No(wo_no_);            
      Accounting_Period_API.Get_Accounting_Year(accounting_year_,accounting_period_,company_,date_created_);      
      acc_period_desc_:= Accounting_Period_API.Get_Description(company_,accounting_year_,accounting_period_);
      part_desc_ := Inventory_Part_API.Get_Description(contract_,part_no_);
   
      Accounting_Period_API.Get_Accounting_Year(accounting_year_,accounting_period_,company_,deinstall_date_);
      deins_acc_period_desc_:= Accounting_Period_API.Get_Description(company_,accounting_year_,accounting_period_);

      Create_Or_Update_Property___(company_,object_id_,'CONTRACT',contract_id_);
      Create_Or_Update_Property___(company_,object_id_,'CUSTOMER',customer_no_);
      Create_Or_Update_Property___(company_,object_id_,'DATEDEP',value_date_ => date_created_);
      Create_Or_Update_Property___(company_,object_id_,'ACCOUNTING_PERIOD',acc_period_desc_);
      Create_Or_Update_Property___(company_,object_id_,'PREV_CONDITION_CODE');
      Create_Or_Update_Property___(company_,object_id_,'CONDITION CODE',condition_code_);
      Create_Or_Update_Property___(company_,object_id_,'DEINSTALLATION_DATE',value_date_ => deinstall_date_);
      Create_Or_Update_Property___(company_,object_id_,'DEINSTALL_ACC_PERIOD',deins_acc_period_desc_);
   END Update_Properties___;
     
   PROCEDURE Create_Manual_Transaction___(
      voucher_amount_ OUT NUMBER,
      wo_no_          IN NUMBER,
      task_seq_       IN NUMBER,
      part_no_        IN VARCHAR2,
      serial_no_      IN VARCHAR2,
      object_id_      IN VARCHAR2,
      spare_contract_ IN VARCHAR2,
      cost_category_  IN VARCHAR2,
      cost_           IN NUMBER)
   IS
      unit_of_measure_ VARCHAR2(10);      
      transaction_id_ NUMBER;
      
      FUNCTION Get_Comment___ RETURN VARCHAR2
      IS
      BEGIN
         RETURN object_id_ || ' ' || part_no_ || ' ' || serial_no_ || ' ' || wo_no_ || ' ' || task_seq_;
      END Get_Comment___;
   BEGIN      
      voucher_amount_ := cost_;
      --unit_of_measure_ := Purchase_Part_Supplier_API.Get_Unit_Meas(spare_contract_, part_no_);
      unit_of_measure_ := Inventory_Part_API.Get_Unit_Meas(spare_contract_, part_no_);
      
      Jt_Task_Transaction_Api.Create_Manual_Transaction(transaction_id_,
                                                        'External',
                                                        task_seq_,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        unit_of_measure_,
                                                        (cost_ * -1), -- total cost = qty * cost
                                                        -1,
                                                        SYSDATE,
                                                        cost_category_,
                                                        Get_Comment___);
                                                          
   END Create_Manual_Transaction___;   
   
PROCEDURE Create_Fixed_Asset_Object___(
      objid_      OUT VARCHAR2,
      objversion_ OUT VARCHAR2,
      object_id_  OUT VARCHAR2,
      company_     IN VARCHAR2,
      task_seq_    IN VARCHAR2,
      part_no_     IN VARCHAR2,
      part_desc_   IN VARCHAR2)
   IS
      info_ VARCHAR2(4000);
      --objid_ VARCHAR2(50);
      --objversion_ VARCHAR(30);
      attr_ VARCHAR2(32000);
      object_class_ VARCHAR2(10);
      aquisition_reason_ VARCHAR2(20);
      account_description_ VARCHAR2(100);
      account_ VARCHAR2(50);
      description_ VARCHAR2(100);
      object_group_id_ VARCHAR2(10) := 'MANAGED';
      pre_accounting_id_ NUMBER;
      
      code_b_ VARCHAR2(20);
      code_c_ VARCHAR2(20);
      code_d_ VARCHAR2(20);
      code_e_ VARCHAR2(20);
      code_f_ VARCHAR2(20);
      code_g_ VARCHAR2(20);
      code_h_ VARCHAR2(20);
      code_j_ VARCHAR2(20);
      
      FUNCTION Get_Attr___ RETURN VARCHAR2
      IS
         attr_ VARCHAR2(32000);
      BEGIN
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
         Client_SYS.Add_To_Attr('DESCRIPTION', part_desc_, attr_);
         Client_SYS.Add_To_Attr('OBJECT_GROUP_ID', object_group_id_, attr_);
         Client_SYS.Add_To_Attr('FA_OBJECT_TYPE', 'Normal', attr_);
         Client_SYS.Add_To_Attr('VALID_FROM', (SYSDATE-1), attr_);
         Client_SYS.Add_To_Attr('VALID_UNTIL', To_Date(Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO'),'YYYYMMDD'),attr_); 
         Client_SYS.Add_To_Attr('OBJECT_CLASS', object_class_, attr_ );
         Client_SYS.Add_To_Attr('ACCOUNT', account_, attr_ );
         Client_SYS.Add_To_Attr('ACQUISITION_REASON', aquisition_reason_, attr_ );
         Client_SYS.Add_To_Attr('INHERIT_DEPR_PLAN', 'FALSE', attr_ );
         Client_SYS.Add_To_Attr('INHERIT_FINAL_DEPR_PERIOD', 'FALSE', attr_ );
         Client_SYS.Add_To_Attr('CODE_B', code_b_, attr_ );
         Client_SYS.Add_To_Attr('CODE_C', code_c_, attr_ );
         Client_SYS.Add_To_Attr('CODE_D', code_d_, attr_ );
         Client_SYS.Add_To_Attr('CODE_E', code_e_, attr_ );
         Client_SYS.Add_To_Attr('CODE_F', code_f_, attr_ );
         Client_SYS.Add_To_Attr('CODE_G', code_g_, attr_ );
         Client_SYS.Add_To_Attr('CODE_H', code_h_, attr_ );
         Client_SYS.Add_To_Attr('CODE_I', '', attr_ );
         Client_SYS.Add_To_Attr('CODE_J', code_j_, attr_ );
         RETURN attr_;
      END Get_Attr___;    
    
   BEGIN
      Fa_Object_Group_API.Get_Object_Group_Info(account_description_,account_,description_,company_,object_group_id_);
      object_class_ := Fa_Object_Group_API.Get_Object_Class(company_,object_group_id_); 
      aquisition_reason_ := Fa_Object_Group_API.Get_Acquisition_Reason(company_,object_group_id_);
      pre_accounting_id_ := Jt_Task_API.Get_Pre_Accounting_Id(task_seq_);     
      Get_Preposting_Data___(code_b_,code_c_,code_d_,code_e_,code_f_,code_g_,code_h_,code_j_,pre_accounting_id_);
      attr_ := Get_Attr___;
      Fa_Object_API.New__(info_,objid_,objversion_,attr_,'DO');
      
      object_id_ := Client_SYS.Get_Item_Value( 'OBJECT_ID', attr_ );
   END Create_Fixed_Asset_Object___;
   
   PROCEDURE Create_Properties___(
      object_id_      IN VARCHAR2,
      company_        IN VARCHAR2,
      contract_       IN VARCHAR2,
      wo_no_          IN NUMBER,
      part_no_        IN VARCHAR2,      
      serial_no_      IN VARCHAR2,
      date_created_   IN DATE,
      condition_code_ IN VARCHAR2)
   IS
      contract_id_ VARCHAR2(20);
      customer_no_ VARCHAR2(20);
      accounting_year_ NUMBER;
      accounting_period_ NUMBER;
      acc_period_desc_ VARCHAR2(50);
      part_desc_ VARCHAR2(100);
   BEGIN
      contract_id_ := Active_Separate_API.Get_Contract_Id(wo_no_);
      customer_no_ := Active_Separate_API.Get_Customer_No(wo_no_);            
      Accounting_Period_API.Get_Accounting_Year(accounting_year_,accounting_period_,company_,date_created_);
      acc_period_desc_:= Accounting_Period_API.Get_Description(company_,accounting_year_,accounting_period_);
      part_desc_ := Inventory_Part_API.Get_Description(contract_,part_no_);
      Create_Property___(company_,object_id_,'CONTRACT',contract_id_); 
      Create_Property___(company_,object_id_,'CUSTOMER',customer_no_); 
      Create_Property___(company_,object_id_,'SERIAL',serial_no_); 
      Create_Property___(company_,object_id_,'PART',part_no_); 
      Create_Property___(company_,object_id_,'DESC',part_desc_);
      Create_Property___(company_,object_id_,'DATEDEP',value_date_ => date_created_); 
      Create_Property___(company_,object_id_,'ACCOUNTING_PERIOD',acc_period_desc_);
      Create_Property___(company_,object_id_,'CONDITION CODE',condition_code_);     
   END Create_Properties___;
   
PROCEDURE Create_Voucher___(      
      company_       IN VARCHAR2,
      voucher_type_  IN VARCHAR2,
      acc_period_   OUT NUMBER,
      acc_year_     OUT NUMBER,
      voucher_no_   OUT VARCHAR2,
      transfer_id_  OUT VARCHAR2,
      objid_        OUT VARCHAR2,
      objversion_   OUT VARCHAR2)
   IS
      attr_ VARCHAR2(32000);
      info_ VARCHAR2(32000);
      
      FUNCTION Get_Attr___(
         prepare_attr_ IN VARCHAR2) RETURN VARCHAR2
      IS
         attr_ VARCHAR2(32000);         
         voucher_status_ VARCHAR2(20) := 'Awaiting Approval';
      BEGIN
         Client_SYS.Clear_Attr(attr_);
         Client_Sys.Add_To_Attr('COMPANY',company_,attr_);
         Client_Sys.Add_To_Attr('VOUCHER_DATE',Client_SYS.Get_Item_Value('DATE_REG',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('USER_GROUP',Client_SYS.Get_Item_Value('USER_GROUP',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('VOUCHER_TYPE',voucher_type_,attr_);
         Client_Sys.Add_To_Attr('VOUCHER_NO',Client_SYS.Get_Item_Value('VOUCHER_NO',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('VOUCHER_STATUS',voucher_status_,attr_);
         Client_Sys.Add_To_Attr('ACCOUNTING_YEAR',Client_SYS.Get_Item_Value('ACCOUNTING_YEAR',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('ACCOUNTING_PERIOD',Client_SYS.Get_Item_Value('ACCOUNTING_PERIOD',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('AMOUNT_METHOD',Client_SYS.Get_Item_Value('AMOUNT_METHOD',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('USE_CORRECTION_ROWS',Client_SYS.Get_Item_Value('USE_CORRECTION_ROWS',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('USERID',Client_SYS.Get_Item_Value('ENTERED_BY_USER_GROUP',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('DATE_REG',Client_SYS.Get_Item_Value('DATE_REG',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('ENTERED_BY_USER_GROUP',Client_SYS.Get_Item_Value('ENTERED_BY_USER_GROUP',prepare_attr_),attr_);
         Client_Sys.Add_To_Attr('FUNCTION_GROUP',voucher_type_,attr_);
         RETURN attr_;   
      END Get_Attr___;
      
      FUNCTION Get_Voucher_No_By_Objid___ RETURN VARCHAR2
      IS
         voicher_no_ VARCHAR2(100);      
      BEGIN
         SELECT voucher_no
           INTO voucher_no_
           FROM voucher
          WHERE objid = objid_;
         RETURN voucher_no_; 
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;    
      END Get_Voucher_No_By_Objid___;      
   BEGIN
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('COMPANY',company_,attr_);
      Client_SYS.Add_To_Attr('VOUCHER_DATE',SYSDATE,attr_);      
      Voucher_API.New__(info_,objid_,objversion_,attr_,'PREPARE');
      
      acc_period_ := Client_SYS.Get_Item_Value('ACCOUNTING_PERIOD',attr_);
      acc_year_ := Client_SYS.Get_Item_Value('ACCOUNTING_YEAR',attr_);
            
      attr_ := Get_Attr___(attr_);      
      Voucher_API.New__(info_,objid_,objversion_,attr_,'DO');
      
      transfer_id_:= Client_SYS.Get_Item_Value('TRANSFER_ID',attr_);
      voucher_no_:= Get_Voucher_No_By_Objid___;      
   END Create_Voucher___;   

PROCEDURE Create_Voucher_Row___(
      company_              IN VARCHAR2,
      account_              IN VARCHAR2,
      account_desc_         IN VARCHAR2,
      currency_code_        IN VARCHAR2,
      currency_type_        IN VARCHAR2,
      curr_credit_amount_   IN NUMBER,
      curr_debit_amount_    IN NUMBER,
      curr_tax_base_amount_ IN NUMBER,
      curr_tax_amount_      IN NUMBER,
      currency_rate_        IN NUMBER,
      conversion_factor_    IN NUMBER,
      credit_amount_        IN NUMBER,
      debit_amount_         IN NUMBER,
      tax_base_amount_      IN NUMBER,
      tax_amount_           IN NUMBER,
      acc_period_           IN NUMBER,
      acc_year_             IN NUMBER,
      auto_tax_vou_entry_   IN VARCHAR2,
      trans_code_           IN VARCHAR2,
      function_group_       IN VARCHAR2,
      transfer_id_          IN VARCHAR2,
      voucher_type_         IN VARCHAR2,
      voucher_no_           IN VARCHAR2,
      object_id_            IN VARCHAR2,
      code_b_               IN VARCHAR2,
      code_d_               IN VARCHAR2,
      code_e_               IN VARCHAR2,
      code_f_               IN VARCHAR2,
      code_i_               IN VARCHAR2,
      text_                 IN VARCHAR2)
   IS
      attr_ VARCHAR2(32000);
      info_ VARCHAR2(32000);
      objid_ VARCHAR2(50);
      objversion_ VARCHAR2(50);
      
      FUNCTION Get_Attr___ RETURN VARCHAR2
      IS
         attr_ VARCHAR2(32000);
      BEGIN
         Client_SYS.Clear_Attr(attr_);
         Client_Sys.Add_To_Attr('COMPANY',company_,attr_);
         Client_Sys.Add_To_Attr('ACCOUNT',account_,attr_);
         Client_Sys.Add_To_Attr('ACCOUNT_DESC',account_desc_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_CODE',currency_code_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_TYPE',currency_type_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_CREDIT_AMOUNT',curr_credit_amount_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_DEBET_AMOUNT',curr_debit_amount_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_TAX_BASE_AMOUNT',curr_tax_base_amount_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_TAX_AMOUNT',curr_tax_amount_,attr_);
         Client_Sys.Add_To_Attr('CURRENCY_RATE',currency_rate_,attr_);
         Client_Sys.Add_To_Attr('CONVERSION_FACTOR',conversion_factor_,attr_);
         Client_Sys.Add_To_Attr('CREDIT_AMOUNT',credit_amount_,attr_);
         Client_Sys.Add_To_Attr('DEBET_AMOUNT',debit_amount_,attr_);
         Client_Sys.Add_To_Attr('TAX_BASE_AMOUNT',tax_base_amount_,attr_);
         Client_Sys.Add_To_Attr('TAX_AMOUNT',tax_amount_,attr_);
         Client_Sys.Add_To_Attr('ACCOUNTING_PERIOD',acc_period_,attr_);
         Client_Sys.Add_To_Attr('AUTO_TAX_VOU_ENTRY',auto_tax_vou_entry_,attr_);
         Client_Sys.Add_To_Attr('TRANS_CODE',trans_code_,attr_);
         Client_Sys.Add_To_Attr('FUNCTION_GROUP',function_group_,attr_);         
         Client_Sys.Add_To_Attr('TRANSFER_ID',transfer_id_,attr_);          
         Client_Sys.Add_To_Attr('ACCOUNTING_YEAR',acc_year_,attr_);          
         Client_Sys.Add_To_Attr('VOUCHER_TYPE',voucher_type_,attr_);          
         Client_Sys.Add_To_Attr('VOUCHER_NO',voucher_no_,attr_); 
         Client_Sys.Add_To_Attr('OBJECT_ID',object_id_,attr_);
         Client_Sys.Add_To_Attr('CODE_B',code_b_,attr_);  
         Client_Sys.Add_To_Attr('CODE_D',code_d_,attr_); 
         Client_Sys.Add_To_Attr('CODE_E',code_e_,attr_); 
         Client_Sys.Add_To_Attr('CODE_F',code_f_,attr_);
         Client_Sys.Add_To_Attr('CODE_I',code_i_,attr_);
         Client_Sys.Add_To_Attr('TEXT',text_,attr_); 
         RETURN attr_;
      END Get_Attr___;
   BEGIN
      attr_:= Get_Attr___;
      Voucher_Row_API.New__(info_,objid_,objversion_,attr_,'DO');   
   END Create_Voucher_Row___;

   PROCEDURE Create_Manual_Voucher___(
      voucher_no_    OUT VARCHAR2,
      voucher_msg_   OUT VARCHAR2,
      acc_year_      OUT NUMBER,
      company_        IN VARCHAR2,
      contract_       IN VARCHAR2,
      object_id_      IN VARCHAR2,
      part_no_        IN VARCHAR2,
      serial_no_      IN VARCHAR2,
      wo_no_          IN VARCHAR2,
      task_seq_       IN VARCHAR2,
      voucher_type_   IN VARCHAR2,      
      voucher_amount_ IN NUMBER)
   IS
      info_ VARCHAR2(2000);
      attr_ VARCHAR2(32000);
      objid_ VARCHAR2(50);
      objversion_ VARCHAR2(30);
      
      acc_period_ NUMBER;
      transfer_id_ varchar2(100);
      amount_ NUMBER := voucher_amount_;
      currency_code_ VARCHAR2(10) := 'GBP';
      currency_type_ NUMBER := 1;
      currency_rate_ NUMBER:= 1;
      conversion_factor_ NUMBER := 1;
      trans_code_ VARCHAR2(10) := 'MANUAL';
      function_group_ VARCHAR2(2) := 'M';
      auto_tax_vou_entry_ VARCHAR2(10) := 'FALSE';
      account_desc_ VARCHAR2(200);
      
      curr_tax_base_amount_ NUMBER;
      curr_tax_amount_ NUMBER;
      tax_base_amount_ NUMBER;
      tax_amount_ NUMBER;
      
      credit_account_ VARCHAR2(20);
      curr_credit_amount_ NUMBER;
      credit_amount_ NUMBER;
      
      debit_account_ VARCHAR2(20);
      curr_debit_amount_ NUMBER;
      debit_amount_ NUMBER;
      
      pre_accounting_id_ NUMBER;
      
      code_b_ VARCHAR2(20);
      code_c_ VARCHAR2(20);
      code_d_ VARCHAR2(20);
      code_e_ VARCHAR2(20);
      code_f_ VARCHAR2(20);
      code_g_ VARCHAR2(20);
      code_h_ VARCHAR2(20);
      code_i_ VARCHAR2(20);
      code_j_ VARCHAR2(20);
      text_ VARCHAR2(200);
      
      PROCEDURE Get_Debit_Amount___(  -- plus amount
         curr_debit_amount_    OUT NUMBER,
         curr_tax_base_amount_ OUT NUMBER,
         curr_tax_amount_      OUT NUMBER,
         debit_amount_         OUT NUMBER,
         tax_base_amount_      OUT NUMBER,
         tax_amount_           OUT NUMBER)
      IS
      BEGIN
         debit_amount_ := amount_; 
         curr_tax_base_amount_ := amount_;
         curr_debit_amount_:= amount_;
         curr_tax_amount_ := 0;
         tax_base_amount_ := amount_;
         tax_amount_ := 0;            
      END Get_Debit_Amount___;
       
      PROCEDURE Get_Credit_Amount___(  -- minus amount
         curr_credit_amount_   OUT NUMBER,
         curr_tax_base_amount_ OUT NUMBER,
         curr_tax_amount_      OUT NUMBER,
         credit_amount_        OUT NUMBER,
         tax_base_amount_      OUT NUMBER,
         tax_amount_           OUT NUMBER)
      IS
      BEGIN
         curr_credit_amount_ := amount_;
         curr_tax_base_amount_ := (- amount_);
         curr_tax_amount_ := 0;
         credit_amount_ := amount_;
         tax_base_amount_ := (- amount_);
         tax_amount_ := 0;  
      END Get_Credit_Amount___;
       
      FUNCTION Get_Credit_Account___ RETURN VARCHAR2
      IS
         account_ VARCHAR2(20);
      BEGIN
         SELECT code_part_value
           INTO account_
           FROM posting_ctrl_detail
          WHERE posting_type = 'TP2'
            AND company = company_
            AND code_name = 'Account'
            AND control_type_value LIKE 'CREATEFA%';
         IF account_ IS NULL THEN    
            SELECT default_value
              INTO account_
              FROM posting_ctrl_master
             WHERE posting_type = 'TP2'
               AND company = company_
               AND code_name = 'Account';
         END IF;
         RETURN account_;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END Get_Credit_Account___;
       
      FUNCTION Get_text___ RETURN VARCHAR2
      IS
      BEGIN
         RETURN part_no_ || '-' || serial_no_ || ' - ' || wo_no_ || ' - ' || task_seq_;
      END Get_text___;
       
      FUNCTION Get_Voucher_Msg___ RETURN VARCHAR2
      IS
      BEGIN
         RETURN company_ ||'^'|| acc_year_ ||'^'|| voucher_type_ ||'^'|| voucher_no_ ||'^$';
      END Get_Voucher_Msg___;
   BEGIN      
      pre_accounting_id_ := Jt_Task_API.Get_Pre_Accounting_Id(task_seq_);
      Get_Preposting_Data___(code_b_,code_c_,code_d_,code_e_,code_f_,code_g_,code_h_,code_j_,pre_accounting_id_);      
              
      Create_Voucher___(company_,voucher_type_,acc_period_,acc_year_,voucher_no_,transfer_id_,objid_,objversion_);      
                
      text_:= Get_text___;
     
      -- Create credit row
      credit_account_ := Get_Credit_Account___;
      Get_Credit_Amount___(curr_credit_amount_,curr_tax_base_amount_,curr_tax_amount_,credit_amount_,tax_base_amount_,tax_amount_);
      account_desc_ := Accounting_Code_Part_A_API.Get_Description(company_,credit_account_);

      debit_amount_ := NULL;
      curr_debit_amount_ := NULL;

      Create_Voucher_Row___(company_,
                            credit_account_,
                            account_desc_,
                            currency_code_,
                            currency_type_,
                            curr_credit_amount_,
                            curr_debit_amount_,
                            curr_tax_base_amount_,
                            curr_tax_amount_,
                            currency_rate_,
                            conversion_factor_,
                            credit_amount_,
                            debit_amount_,
                            tax_base_amount_,
                            tax_amount_,
                            acc_period_,
                            acc_year_,
                            auto_tax_vou_entry_,
                            trans_code_,
                            function_group_,
                            transfer_id_,
                            voucher_type_,
                            voucher_no_,
                            object_id_,
                            code_b_,
                            code_d_,
                            code_e_,
                            code_f_,
                            code_i_,
                            text_);
      
      --Create debit row
      debit_account_ := Fa_Object_API.Get_Account(company_,object_id_);
      dbms_output.put_line('Debit Account: '|| debit_account_);
      Get_Debit_Amount___(curr_debit_amount_,curr_tax_base_amount_,curr_tax_amount_,debit_amount_,tax_base_amount_,tax_amount_);
      account_desc_ := Accounting_Code_Part_A_API.Get_Description(company_,debit_account_);
      
      credit_amount_ := NULL;
      curr_credit_amount_ := NULL;
      code_b_ := NULL;
      code_e_ := NULL;
      code_i_ := object_id_;
      
      Create_Voucher_Row___(company_,
                            debit_account_,
                            account_desc_,
                            currency_code_,
                            currency_type_,
                            curr_credit_amount_,
                            curr_debit_amount_,
                            curr_tax_base_amount_,
                            curr_tax_amount_,
                            currency_rate_,
                            conversion_factor_,
                            credit_amount_,
                            debit_amount_,
                            tax_base_amount_,
                            tax_amount_,
                            acc_period_,
                            acc_year_,
                            auto_tax_vou_entry_,
                            trans_code_,
                            function_group_,
                            transfer_id_,
                            voucher_type_,
                            voucher_no_,
                            object_id_,
                            code_b_,
                            code_d_,
                            code_e_,
                            code_f_,
                            code_i_,
                            text_);
      
      Voucher_API.Ready_Approve__(info_,objid_,objversion_,attr_,'DO');
      Voucher_API.Finalize_Manual_Voucher__(voucher_no_,company_,voucher_type_,transfer_id_);      
      Voucher_Row_API.Update_Vou_Row_Acc_Period__(company_,acc_year_,voucher_no_,voucher_no_,acc_period_);
      voucher_msg_ := Get_Voucher_Msg___;
   END Create_Manual_Voucher___;
   
PROCEDURE Approve_Manual_Voucher___ (
      company_           IN VARCHAR2,
      voucher_no_        IN VARCHAR2,
      voucher_type_      IN VARCHAR2,
      accounting_year_   IN NUMBER)
   IS
      rec_ Voucher_API.Public_Rec;
      attr_ VARCHAR2(2000);
      info_ VARCHAR2(2000);
      objid_ VARCHAR2(30);
      objversion_ VARCHAR2(30);
      
      FUNCTION Get_Attr___ RETURN VARCHAR2
      IS
         attr_ VARCHAR2(2000);
         voucher_status_ VARCHAR2(10) := 'Approved';
         amount_method_ VARCHAR2(50) := Def_Amount_Method_API.Decode(rec_.amount_method);
      BEGIN
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('USER_GROUP',rec_.user_group,attr_);
         Client_SYS.Add_To_Attr('VOUCHER_STATUS',voucher_status_,attr_);
         Client_SYS.Add_To_Attr('ACCOUNTING_YEAR',rec_.accounting_year,attr_);
         Client_SYS.Add_To_Attr('ACCOUNTING_PERIOD',rec_.accounting_period,attr_);
         Client_SYS.Add_To_Attr('AMOUNT_METHOD',amount_method_,attr_);
         Client_SYS.Add_To_Attr('ENTERED_BY_USER_GROUP',rec_.user_group,attr_);
         Client_SYS.Add_To_Attr('FUNCTION_GROUP',rec_.function_group,attr_);
         RETURN attr_;  
      END Get_Attr___;
   BEGIN
      rec_ := Voucher_API.Get(company_,accounting_year_,voucher_type_,voucher_no_);
      objid_ := rec_."rowid";
      objversion_ := to_char(rec_.rowversion,'YYYYMMDDHH24MISS');
      attr_ := Get_Attr___;
      
      dbms_output.put_line(rec_.amount_method);
      dbms_output.put_line(objversion_);
      Voucher_API.Modify__(info_,objid_,objversion_,attr_,'DO');

      attr_ := NULL;
      Voucher_API.Ready_To_Update__(info_,objid_,objversion_,attr_,'DO');
   END Approve_Manual_Voucher___; 
   
   PROCEDURE Update_General_Ledger___(
       company_     IN VARCHAR2,
       voucher_msg_ IN VARCHAR2)
   IS
       jou_no_ NUMBER;
       internal_seq_number_ NUMBER;
       no_of_vouchers_ NUMBER;
       error_count_ NUMBER;
       action_ VARCHAR2(10) := 'EXEC';
   BEGIN
      dbms_output.put_line(voucher_msg_);
      Gen_Led_Voucher_Update_API.Instant_Update(jou_no_,
                                                internal_seq_number_,
                                                no_of_vouchers_,
                                                error_count_,
                                                voucher_msg_,
                                                action_,
                                                company_,
                                                'N',
                                                'N');
   END Update_General_Ledger___;
   
   PROCEDURE Update_Object_Status___(
      objid_       IN OUT VARCHAR2,
      objversion_  IN OUT VARCHAR2,
      status_code_     IN VARCHAR2)
   IS
      attr_ VARCHAR2(1000);
      info_ VARCHAR2(1000);
   BEGIN
      IF status_code_ = 'INVESTMENT' THEN
         Fa_Object_API.Invest__(info_,objid_,objversion_,attr_,'DO'); 
      ELSIF status_code_ = 'ACTIVE' THEN
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('ACQUISITION_DATE',SYSDATE,attr_);
         Fa_Object_API.Activate_Investment__(info_,objid_,objversion_,attr_,'DO');
      END IF;
   END Update_Object_Status___;   
--C0360 EntPrageG (END) 
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
--C0360 EntPrageG (START)   
PROCEDURE Create_Fixed_Asset_Object_
IS
   objid_       VARCHAR2(50);
   objversion_  VARCHAR2(30);
   object_id_   VARCHAR2(20);
   cost_ NUMBER;
   
   voucher_msg_ VARCHAR2(100);
   voucher_no_ VARCHAR2(20);
   acc_year_ NUMBER;
   voucher_type_ VARCHAR2(2) := 'M';
   voucher_amount_ NUMBER;             
  
   success_ BOOLEAN := FALSE;
   
   PROCEDURE Remove_Default_property_Codes___(
      object_id_ IN VARCHAR2)
   IS
      info_ VARCHAR2(4000);
   BEGIN
      FOR rec_ IN ( SELECT objid,objversion 
                      FROM fa_object_property 
                     WHERE object_id = object_id_) LOOP
         Fa_Object_Property_API.Remove__(info_,rec_.objid,rec_.objversion,'DO');   
      END LOOP;
   END Remove_Default_property_Codes___; 
   
   FUNCTION Get_Cost___ (
      part_no_ IN VARCHAR2,
      serial_no_ IN VARCHAR2,
      contract_  IN VARCHAR2,
      task_seq_ IN VARCHAR2)RETURN NUMBER
   IS
      comment_ VARCHAR2(200);
      cost_ NUMBER;
   BEGIN
      comment_ := 'Part no: '||part_no_||': Serial No: '||serial_no_||': Site: '||contract_;       
      SELECT SUM(cost_amount)
        INTO cost_
        FROM jt_task_cost_line_uiv
       WHERE report_comment = comment_
         AND task_seq = task_seq_; 
      RETURN cost_;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END Get_Cost___;
BEGIN    
   Log_Progress___('Create FA Objects - Started'); 
   FOR req_line_rec_ IN  get_material_req_lines      
      LOOP
      FOR trans_his_line_rec_ IN get_inventory_transaction_history_line(req_line_rec_.wo_no, 
                                                                        req_line_rec_.maint_material_order_no,
                                                                        req_line_rec_.contract,
                                                                        req_line_rec_.part_no)                                                                              
      LOOP
         BEGIN
            IF NOT Fixed_Asset_Object_Exist___(object_id_,trans_his_line_rec_.part_no,trans_his_line_rec_.serial_no) THEN            
               Log_Info___('Creating Object - Wo No: '|| req_line_rec_.wo_no||
                           ' Part No: ' || trans_his_line_rec_.part_no || 
                           ' Serial No: ' || trans_his_line_rec_.serial_no);   
               Create_Fixed_Asset_Object___(objid_,
                                            objversion_,
                                            object_id_,
                                            trans_his_line_rec_.company,
                                            trans_his_line_rec_.task_seq,
                                            trans_his_line_rec_.part_no,
                                            trans_his_line_rec_.part_desc);
               Log_Info___('Object Created! ' || object_id_);
               
               Log_Info___('Updating object status to investment');
               Update_Object_Status___(objid_,objversion_,'INVESTMENT');
               
               --Log_Info___('Removing default property codes');                              
               Remove_Default_property_Codes___(object_id_);   
               
               Log_Info___('Adding Object Properties');         
               Create_Properties___(object_id_,
                                    trans_his_line_rec_.company,
                                    req_line_rec_.contract,
                                    req_line_rec_.wo_no,
                                    trans_his_line_rec_.part_no,
                                    trans_his_line_rec_.serial_no,
                                    trans_his_line_rec_.date_created,
                                    trans_his_line_rec_.condition_code);
                                    
               Log_Info___('Creating manual transaction'); 
               cost_ := Get_Cost___(req_line_rec_.part_no,
                                    trans_his_line_rec_.serial_no,
                                    req_line_rec_.spare_contract,
                                    req_line_rec_.task_seq);

               Create_Manual_Transaction___ (voucher_amount_,
                                             req_line_rec_.wo_no,
                                             req_line_rec_.task_seq,
                                             req_line_rec_.part_no,
                                             trans_his_line_rec_.serial_no,
                                             object_id_,
                                             req_line_rec_.spare_contract,
                                             'CREATEFA',
                                             cost_);
                                             
               Log_Info___('Creating manual voucher');                                                      
               Create_Manual_Voucher___(voucher_no_,
                                        voucher_msg_,
                                        acc_year_,
                                        trans_his_line_rec_.company,
                                        req_line_rec_.contract,
                                        object_id_,
                                        req_line_rec_.part_no,
                                        trans_his_line_rec_.serial_no,
                                        req_line_rec_.wo_no,
                                        req_line_rec_.task_seq,
                                        voucher_type_,
                                        voucher_amount_);
                                        
               Log_Info___('Approving manual voucher');
               Approve_Manual_Voucher___(trans_his_line_rec_.company,voucher_no_,voucher_type_,acc_year_);
               
               Log_Info___('Updating General Ledger');                      
               Update_General_Ledger___(trans_his_line_rec_.company,voucher_msg_);
               
               Log_Info___('Updating object status to Active');
               Update_Object_Status___(objid_,objversion_,'ACTIVE');
               success_ := TRUE;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               Log_Warning___(SUBSTR(SQLERRM, 1, 200));
         END;
      END LOOP;      
   END LOOP;   
   IF NOT success_ THEN
      Log_Progress___('Create FA Objects - Completed with warnings! please check the log');
      Log_Info___('No FA Objects Ceated!');
   ELSE
      Log_Progress___('Create FA Objects - Completed');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      Log_Error___(SUBSTR(SQLERRM, 1, 200));
END Create_Fixed_Asset_Object_;
--C0360 EntPrageG (END) 

PROCEDURE Reissue_Asset_Object_
IS
   object_id_   VARCHAR2(20);
   deinstall_date_ DATE;
   
   success_ BOOLEAN := FALSE;
   
   FUNCTION Get_Deinstallation_Date___(
      wo_no_            IN VARCHAR2,
      task_seq_         IN VARCHAR2,
      maint_mat_ord_no_ IN VARCHAR2,
      line_item_no_     IN VARCHAR2,
      part_no_          IN VARCHAR2,
      serial_no_        IN VARCHAR2) RETURN DATE
   IS
      date_created_ DATE;
   BEGIN
      SELECT date_created
        INTO date_created_
        FROM inventory_transaction_hist2
       WHERE source_ref1 = TRIM(wo_no_)
         AND source_ref2 = task_seq_
         AND source_ref3 = maint_mat_ord_no_
         AND source_ref4 = line_item_no_
         AND part_no = part_no_
         AND serial_no = serial_no_;
      RETURN date_created_;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END Get_Deinstallation_Date___;         
BEGIN
   Log_Progress___('Reissue FA Objects - Started'); 
   FOR req_line_rec_ IN  get_material_req_lines
   LOOP      
      FOR trans_his_line_rec_ IN get_inventory_transaction_history_line(req_line_rec_.wo_no, 
                                                                        req_line_rec_.maint_material_order_no,
                                                                        req_line_rec_.contract,
                                                                        req_line_rec_.part_no)                                                                              
      LOOP
         BEGIN
            IF Fixed_Asset_Object_Exist___(object_id_,trans_his_line_rec_.part_no,trans_his_line_rec_.serial_no) THEN
               IF Contract_Has_Changed___(trans_his_line_rec_.company,object_id_,req_line_rec_.task_seq) THEN
                  
                  Log_Info___('Updating Object '|| object_id_);
                  Update_Fixed_Asset_Object___(trans_his_line_rec_.company,object_id_,req_line_rec_.task_seq); 
                  deinstall_date_ := Get_Deinstallation_Date___(req_line_rec_.wo_no,
                                                                req_line_rec_.task_seq,
                                                                req_line_rec_.maint_material_order_no,
                                                                req_line_rec_.line_item_no,
                                                                req_line_rec_.part_no,
                                                                trans_his_line_rec_.serial_no);
                  Log_Info___('Updating Object properties');                                              
                  Update_Properties___(object_id_,
                                       trans_his_line_rec_.company,
                                       req_line_rec_.contract,
                                       req_line_rec_.wo_no,
                                       req_line_rec_.part_no,
                                       trans_his_line_rec_.date_created,
                                       trans_his_line_rec_.condition_code,                                    
                                       trans_his_line_rec_.date_created); 
                  success_ := TRUE;
               END IF;   
            END IF;
         EXCEPTION
               WHEN OTHERS THEN
                  Log_Warning___(SUBSTR(SQLERRM, 1, 200));
         END;
      END LOOP;      
   END LOOP;
   IF NOT success_ THEN
      Log_Info___('No FA Objects Reissued!');   
   END IF;
   Log_Progress___('Reissue FA Objects - Completed'); 
EXCEPTION
   WHEN OTHERS THEN
      Log_Error___(SUBSTR(SQLERRM, 1, 200));
END Reissue_Asset_Object_;

PROCEDURE Return_Obj_To_Fa_Stock_Pool_
IS
   object_id_ VARCHAR2(20);
   
   success_ BOOLEAN := FALSE;
   
   CURSOR work_order_returns
    IS
      SELECT part_no,
             serial_no,
             contract,
             Site_API.Get_Company(contract) company,
             cf$_created_date date_created
        FROM work_order_returns_uiv_cfv
       WHERE condition_code = 'FATBR';
       
   PROCEDURE Update_Fixed_Asset_Object___(
      company_   IN VARCHAR2,
      object_id_ IN VARCHAR2)
   IS
      info_ VARCHAR2(4000);
      objid_ VARCHAR2(50);
      objversion_ VARCHAR2(30);
      attr_ VARCHAR2(32000);
      
      code_f_ VARCHAR2(10) := NULL;
      
      object_rec_ Fa_Object_API.Public_Rec;
      
      FUNCTION Get_Attr___ RETURN VARCHAR2
      IS
         attr_ VARCHAR2(32000);
      BEGIN
         Client_SYS.Clear_Attr(attr_);
         Client_SYS.Add_To_Attr('CODE_F', code_f_, attr_ );
         RETURN attr_;
      END Get_Attr___; 
   BEGIN
      object_rec_ := Fa_Object_API.Get(company_,object_id_);
      attr_ := Get_Attr___;
      objid_ := object_rec_."rowid";
      objversion_ := to_char(object_rec_.rowversion,'YYYYMMDDHH24MISS');
      
      Fa_Object_API.Modify__(info_,objid_,objversion_,attr_,'DO');
   END Update_Fixed_Asset_Object___;

   PROCEDURE Update_Properties___(
      object_id_        IN VARCHAR2,
      company_          IN VARCHAR2,      
      date_created_     IN DATE)
   IS     
      contract_ VARCHAR2(20) := NULL;
      customer_no_ VARCHAR2(20) := NULL;
      accounting_year_ NUMBER;
      accounting_period_ NUMBER;
      deins_acc_period_desc_ VARCHAR2(50);
      deinstall_date_ DATE;
      condition_code_ VARCHAR2(10) := 'FATBR';
   BEGIN     
      deinstall_date_ := date_created_;      
      Accounting_Period_API.Get_Accounting_Year(accounting_year_,accounting_period_,company_,deinstall_date_);
      deins_acc_period_desc_:= Accounting_Period_API.Get_Description(company_,accounting_year_,accounting_period_);
      
      Create_Or_Update_Property___(company_,object_id_,'CONTRACT',contract_);
      Create_Or_Update_Property___(company_,object_id_,'CUSTOMER',customer_no_);
      Create_Or_Update_Property___(company_,object_id_,'PREV_CONDITION_CODE',condition_code_);
      Create_Or_Update_Property___(company_,object_id_,'CONDITION CODE',condition_code_);
      Create_Or_Update_Property___(company_,object_id_,'DEINSTALLATION_DATE',value_date_ => deinstall_date_);
      Create_Or_Update_Property___(company_,object_id_,'DEINSTALL_ACC_PERIOD',deins_acc_period_desc_);
   END Update_Properties___;   

BEGIN
   Log_Progress___('Return FA Objects to FA Stock Pool - Started'); 
   FOR rec_ IN work_order_returns LOOP
      BEGIN
         IF Fixed_Asset_Object_Exist___(object_id_,rec_.part_no, rec_.serial_no) THEN
            Log_Info___('Updating Object '|| object_id_);
            Update_Fixed_Asset_Object___(rec_.company,object_id_); 
            
            Log_Info___('Updating Object properties');
            Update_Properties___(object_id_,rec_.company,rec_.date_created);         
         END IF;
      EXCEPTION
            WHEN OTHERS THEN
               Log_Warning___(SUBSTR(SQLERRM, 1, 200) || 'Object ID ' || object_id_);
      END;
   END LOOP;
   IF NOT success_ THEN
      Log_Info___('No FA Objects Returned!');   
   END IF;
   Log_Progress___('Return FA Objects to FA Stock Pool - Completed'); 
EXCEPTION
   WHEN OTHERS THEN
      Log_Error___(SUBSTR(SQLERRM, 1, 200));   
END Return_Obj_To_Fa_Stock_Pool_;

PROCEDURE Scrap_Object_From_Fa_Register_
IS
   object_id_ VARCHAR2(20);
   state_ VARCHAR2(20);
   disposal_reason_ VARCHAR2(20) := 'SCRAPMSFA';
   
   success_ BOOLEAN := FALSE;
   
   CURSOR get_scrap_inventory
      IS
        SELECT Site_API.Get_Company(contract) company,
               part_no,
               serial_no
          FROM inventory_transaction_hist
         WHERE serial_no IS NOT NULL
           AND date_created < (SYSDATE - 1);
BEGIN
   Log_Progress___('Scrap FA Objects From FA Register - Started');
   FOR scrap_inventory_rec_ IN get_scrap_inventory
   LOOP
      BEGIN
         IF Fixed_Asset_Object_Exist___(object_id_,scrap_inventory_rec_.part_no,scrap_inventory_rec_.serial_no) THEN
            state_ := Fa_Object_API.Get_State(scrap_inventory_rec_.company, object_id_);
            IF state_ != 'Scrapped' THEN
               Log_Info___('Scrapping FA Object '|| object_id_);
               Scrap_Fa_Object___(scrap_inventory_rec_.company,object_id_,disposal_reason_);   
            END IF;   
         END IF;
         success_ := TRUE;
      EXCEPTION
         WHEN OTHERS THEN
            Log_Warning___(SUBSTR(SQLERRM, 1, 200));
      END;
   END LOOP;
   IF NOT success_ THEN
      Log_Info___('No FA Objects Scrapped!');   
   END IF;
   Log_Progress___('Scrap FA Objects From FA Register - Completed');   
EXCEPTION
   WHEN OTHERS THEN
      Log_Error___(SUBSTR(SQLERRM, 1, 200));
END Scrap_Object_From_Fa_Register_;

PROCEDURE Scrap_Non_Fa_Contract_Object_
IS
   object_id_ VARCHAR2(20);
   cost_ NUMBER;   
   voucher_amount_ NUMBER;
   disposal_reason_ VARCHAR2(20) := 'SCRAPSERVCON';
   
   success_ BOOLEAN;
   
   FUNCTION Get_Book_Id___(
      company_   IN VARCHAR2,
      object_id_ IN VARCHAR2) RETURN VARCHAR2
   IS
      book_id_ VARCHAR2(10);
   BEGIN
      SELECT book_id
        INTO book_id_
        FROM fa_book_per_object
       WHERE company = company_
         AND object_id = object_id_;
      RETURN book_id_;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END Get_Book_Id___;
   
   FUNCTION Get_Cost___ (
      company_ IN VARCHAR2,
      object_id_ IN VARCHAR2)RETURN NUMBER
   IS
      attr_ VARCHAR2(100);
      fa_calendar_id_ VARCHAR2(10) := 'FA';
      fa_year_ NUMBER;
      fa_period_ NUMBER;
      event_date_ DATE;
      book_id_ VARCHAR2(10);
   BEGIN
      attr_:= Fa_Accounting_Period_API.Get_Fa_Year_Period(company_,TRUNC(SYSDATE),fa_calendar_id_);
      fa_year_:= Client_SYS.Get_Item_Value('FA_YEAR',attr_);
      fa_period_:= Client_SYS.Get_Item_Value('FA_PERIOD',attr_);
      book_id_ := Get_Book_Id___(company_,object_id_);
      event_date_ := Fa_Accounting_Period_API.Get_To_Date(company_,fa_year_,fa_period_,fa_calendar_id_);
      cost_ := Fa_Book_Per_Object_API.Get_Net_Value_At_Date(company_,object_id_,book_id_,fa_year_,fa_period_,fa_calendar_id_,event_date_);
      RETURN cost_;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END Get_Cost___;
BEGIN
   Log_Progress___('Scrap None FA Contract FA Objects - Started'); 
   FOR req_line_rec_ IN  get_material_req_lines
   LOOP
      FOR trans_his_line_rec_ IN get_inventory_transaction_history_line(req_line_rec_.wo_no, 
                                                                         req_line_rec_.maint_material_order_no,
                                                                         req_line_rec_.contract,
                                                                         req_line_rec_.part_no)                                                                              
      LOOP         
         BEGIN
            IF NOT Fa_Contract___(req_line_rec_.contract_type) AND Convert_To_Fa___(req_line_rec_.contract,req_line_rec_.part_no) THEN
               IF Fixed_Asset_Object_Exist___(object_id_,trans_his_line_rec_.part_no,trans_his_line_rec_.serial_no) THEN              
                  Log_Info___('Updating FA Object ' || object_id_);
                  Update_Fixed_Asset_Object___(trans_his_line_rec_.company,object_id_,req_line_rec_.task_seq);
                  Log_Info___('Updating FA Properties');
                  Update_Properties___(object_id_,
                                       trans_his_line_rec_.company,
                                       req_line_rec_.contract,
                                       req_line_rec_.wo_no,                                    
                                       req_line_rec_.part_no,
                                       trans_his_line_rec_.date_created,
                                       trans_his_line_rec_.condition_code,
                                       SYSDATE); 
                  Log_Info___('Scrapping FA Object');      
                  Scrap_Fa_Object___(trans_his_line_rec_.company,object_id_,disposal_reason_);

                  cost_ := Get_Cost___(trans_his_line_rec_.company,object_id_);
                  Log_Info___('Creating Manual Transactions'); 
                  Create_Manual_Transaction___ (voucher_amount_,
                                                req_line_rec_.wo_no,
                                                req_line_rec_.task_seq,
                                                req_line_rec_.part_no,
                                                trans_his_line_rec_.serial_no,
                                                object_id_,
                                                req_line_rec_.spare_contract,
                                                'CONVERTFA',
                                                cost_);
                  success_ := TRUE;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               Log_Warning___(SUBSTR(SQLERRM, 1, 200));
         END;          
      END LOOP;   
   END LOOP;
   IF NOT success_ THEN
      Log_Info___('No FA Objects Scrapped!');   
   END IF;
   Log_Progress___('Scrap None FA Contract FA Objects - Completed');
EXCEPTION
   WHEN OTHERS THEN
         Log_Error___(SUBSTR(SQLERRM, 1, 200));      
END Scrap_Non_Fa_Contract_Object_;

-------------------- LU  NEW METHODS -------------------------------------
