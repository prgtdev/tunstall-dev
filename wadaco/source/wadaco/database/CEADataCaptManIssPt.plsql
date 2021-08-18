-----------------------------------------------------------------------------
--
--  Logical unit: CEADataCaptManIssPt
--  Component:    WADACO
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

FUNCTION Get_Unique_Data_Item_Value___ (
   contract_                   IN VARCHAR2,
   order_no_                   IN VARCHAR2,
   release_no_                 IN VARCHAR2,
   sequence_no_                IN VARCHAR2,
   part_no_                    IN VARCHAR2,
   eng_chg_level_              IN VARCHAR2,
   activity_seq_               IN NUMBER,
   condition_code_             IN VARCHAR2,
   waiv_dev_rej_no_            IN VARCHAR2,
   component_part_no_          IN VARCHAR2,
   line_item_no_               IN NUMBER,
   operation_no_               IN NUMBER,
   location_no_                IN VARCHAR2,
   lot_batch_no_               IN VARCHAR2,
   serial_no_                  IN VARCHAR2,
   handling_unit_id_           IN NUMBER,
   alt_handling_unit_label_id_ IN VARCHAR2,
   barcode_id_                 IN NUMBER,
   wanted_data_item_id_        IN VARCHAR2 ) RETURN VARCHAR2;

PROCEDURE Get_Filter_Keys___ (
   contract_                   OUT VARCHAR2,
   order_no_                   OUT VARCHAR2,
   release_no_                 OUT VARCHAR2,
   sequence_no_                OUT VARCHAR2,
   part_no_                    OUT VARCHAR2,
   eng_chg_level_              OUT VARCHAR2,
   activity_seq_               OUT NUMBER,
   condition_code_             OUT VARCHAR2,
   waiv_dev_rej_no_            OUT VARCHAR2,
   component_part_no_          OUT VARCHAR2,
   line_item_no_               OUT NUMBER,
   operation_no_               OUT NUMBER,
   location_no_                OUT VARCHAR2,
   lot_batch_no_               OUT VARCHAR2,
   serial_no_                  OUT VARCHAR2,
   barcode_id_                 OUT NUMBER,
   gtin_no_                    OUT VARCHAR2,
   handling_unit_id_           OUT NUMBER,
   sscc_                       OUT VARCHAR2,  
   alt_handling_unit_label_id_ OUT VARCHAR2,
   capture_session_id_         IN  NUMBER,
   data_item_id_               IN  VARCHAR2,
   data_item_value_            IN  VARCHAR2 DEFAULT NULL,
   use_unique_values_          IN  BOOLEAN  DEFAULT FALSE,
   use_applicable_             IN  BOOLEAN  DEFAULT TRUE );

PROCEDURE Add_Filter_Key_Detail___ (
   capture_session_id_         IN NUMBER,
   owning_data_item_id_        IN VARCHAR2,
   data_item_detail_id_        IN VARCHAR2,
   order_no_                   IN VARCHAR2,
   release_no_                 IN VARCHAR2,
   sequence_no_                IN VARCHAR2,
   part_no_                    IN VARCHAR2,
   eng_chg_level_              IN VARCHAR2,
   activity_seq_               IN NUMBER,
   condition_code_             IN VARCHAR2,
   waiv_dev_rej_no_            IN VARCHAR2,
   component_part_no_          IN VARCHAR2,
   line_item_no_               IN NUMBER,
   operation_no_               IN NUMBER,
   location_no_                IN VARCHAR2,
   lot_batch_no_               IN VARCHAR2,
   serial_no_                  IN VARCHAR2,
   handling_unit_id_           IN NUMBER,
   sscc_                       IN VARCHAR2,
   alt_handling_unit_label_id_ IN VARCHAR2,
   barcode_id_                 IN NUMBER,
   gtin_no_                    IN VARCHAR2);

PROCEDURE Add_Unique_Data_Item_Detail___ (
   capture_session_id_         IN NUMBER,
   session_rec_                IN Data_Capture_Common_Util_API.Session_Rec,
   owning_data_item_id_        IN VARCHAR2,
   owning_data_item_value_     IN VARCHAR2,
   data_item_detail_id_        IN VARCHAR2 );

PROCEDURE Validate_Data_Item___ (
   contract_                   IN VARCHAR2,
   order_no_                   IN VARCHAR2,
   release_no_                 IN VARCHAR2,
   sequence_no_                IN VARCHAR2,
   line_item_no_               IN NUMBER,
   component_part_no_          IN VARCHAR2,
   location_no_                IN VARCHAR2,
   lot_batch_no_               IN VARCHAR2,
   serial_no_                  IN VARCHAR2,
   eng_chg_level_              IN VARCHAR2,
   waiv_dev_rej_no_            IN VARCHAR2,
   configuration_id_           IN VARCHAR2,
   activity_seq_               IN NUMBER,
   handling_unit_id_           IN NUMBER,
   alt_handling_unit_label_id_ IN VARCHAR2,
   data_item_id_               IN VARCHAR2,
   data_item_value_            IN VARCHAR2,
   capture_session_id_         IN NUMBER);

FUNCTION Get_Sql_Where_Expression___ (
   order_no_                 IN VARCHAR2,
   release_no_               IN VARCHAR2,
   sequence_no_              IN VARCHAR2,
   line_item_no_             IN NUMBER,
   unique_type_              IN VARCHAR2 DEFAULT 'NORMAL' ) RETURN VARCHAR2;

FUNCTION Get_Input_Uom_Sql_Whr_Exprs___  RETURN VARCHAR2;

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
-----------------------------------------------------------------------------

PROCEDURE Validate_Data_Item (
   capture_session_id_  IN NUMBER,
   data_item_id_        IN VARCHAR2,
   data_item_value_     IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      capture_session_id_  IN NUMBER,
      data_item_id_        IN VARCHAR2,
      data_item_value_     IN VARCHAR2 )
   IS
      contract_                   VARCHAR2(5);
      order_no_                   VARCHAR2(12);
      release_no_                 VARCHAR2(4);
      sequence_no_                VARCHAR2(4);
      part_no_                    VARCHAR2(25);
      component_part_no_          VARCHAR2(25);
      lot_batch_no_               VARCHAR2(20);
      eng_chg_level_              VARCHAR2(6);
      waiv_dev_rej_no_            VARCHAR2(15);
      activity_seq_               NUMBER;
      shopord_activity_seq_       NUMBER;
      condition_code_             VARCHAR2(10);
      data_item_description_      VARCHAR2(200);
      line_item_no_               NUMBER;
      operation_no_               NUMBER;
      serial_no_                  VARCHAR2(50);
      location_no_                VARCHAR2(35);
      configuration_id_           VARCHAR2(50);
      local_data_item_id_         VARCHAR2(50);
      barcode_id_                 NUMBER;
      gtin_no_                    VARCHAR2(14);
      sql_where_expression_       VARCHAR2(2000);
      handling_unit_id_           NUMBER;
      sscc_                       VARCHAR2(18);
      alt_handling_unit_label_id_ VARCHAR2(25);
      session_rec_                Data_Capture_Common_Util_API.Session_Rec;
      process_package_            VARCHAR2(30);
      catch_quantity_             NUMBER;
      quantity_                   NUMBER;
      input_unit_meas_group_id_   VARCHAR2(30);
      gtin_part_no_               VARCHAR2(25);
      local_component_part_no_    VARCHAR2(25);
      local_condition_code_       VARCHAR2(10);
      
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         IF (data_item_id_ = 'BARCODE_ID') THEN
            -- Note: No need to get values for process keys when barcode_id is null because probably it would not be used in this process.
            IF (data_item_value_ IS NOT NULL) THEN
               -- We need a complete set of filter keys fetched with unique handling so we can find a possible unique barcode and filter it correctly
               Get_Filter_Keys___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                  component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                                  handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_,
                                  data_item_value_, use_unique_values_ => TRUE);
            END IF;
         ELSE
            Get_Filter_Keys___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                               component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                               handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_, data_item_value_);
         END IF;
   
         IF data_item_id_ IN ('INPUT_QUANTITY') THEN
            quantity_ := data_item_value_;
            IF (quantity_ <= 0) THEN
               Error_SYS.Record_General(lu_name_,'QUANTITYVALIDATION: Input quantity must be greater than or equal to 0(zero).');
            END IF;  
         END IF;
   
         IF (data_item_id_ IN ('PART_NO','CATCH_QUANTITY')) THEN
            session_rec_     := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
            process_package_ := Data_Capture_Process_API.Get_Process_Package(session_rec_.capture_process_id);
            catch_quantity_ := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'CATCH_QUANTITY', session_rec_ , process_package_);
            -- NOTE: We are using PART_NO and not COMPONENT_PART_NO at the moment since it was so before also, but maybe it should be COMPONENT_PART_NO used here? 
            -- In that case change parameter sent into method to component_part_no_ and the data_item_id_ value and part_no_data_item_id_ to 'COMPONENT_PART_NO' in if statement and in the call to this method below. 
            Data_Capture_Invent_Util_API.Check_Catch_Qty(capture_session_id_        => capture_session_id_,        
                                                         current_data_item_id_      => data_item_id_,
                                                         part_no_data_item_id_      => 'PART_NO',
                                                         part_no_data_item_value_   => part_no_,
                                                         catch_qty_data_item_id_    => 'CATCH_QUANTITY',
                                                         catch_qty_data_item_value_ => catch_quantity_,
                                                         positive_catch_qty_        => TRUE);
         END IF;
   
         data_item_description_ := Data_Capt_Proc_Data_Item_API.Get_Description(Data_Capture_Session_API.Get_Capture_Process_Id(capture_session_id_), data_item_id_);
         IF (activity_seq_ = 0) THEN
            shopord_activity_seq_ := NULL;  -- shop_ord have NULL instead of 0 for non project parts
         ELSE
            shopord_activity_seq_ := activity_seq_;
         END IF;
         configuration_id_ := NVL(Shop_Material_Alloc_API.Get_Configuration_Id(order_no_, release_no_, sequence_no_, line_item_no_), '*');
   
         IF (data_item_id_ IN ('COMPONENT_PART_NO', 'LOT_BATCH_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO', 'ACTIVITY_SEQ') AND
             barcode_id_ IS NOT NULL) THEN
            -- BARCODE_ID is used for these items, then validate them against the barcode table, since there are so
            -- many different checks concerning serial_no in Validate_Data_Item___ item SERIAL_NO is not handled here
            IF (data_item_id_ = 'COMPONENT_PART_NO') THEN
               local_data_item_id_ := 'PART_NO';
            ELSE
               local_data_item_id_ := data_item_id_;
            END IF;
            Inventory_Part_Barcode_API.Record_With_Column_Value_Exist(contract_           => contract_,
                                                                      barcode_id_         => barcode_id_,
                                                                      part_no_            => component_part_no_,
                                                                      configuration_id_   => configuration_id_,
                                                                      lot_batch_no_       => lot_batch_no_,
                                                                      serial_no_          => serial_no_,
                                                                      eng_chg_level_      => eng_chg_level_,
                                                                      waiv_dev_rej_no_    => waiv_dev_rej_no_,
                                                                      activity_seq_       => activity_seq_,
                                                                      column_name_        => local_data_item_id_,
                                                                      column_value_       => data_item_value_,
                                                                      column_description_ => data_item_description_);
         ELSIF (data_item_id_ IN ('ORDER_NO', 'RELEASE_NO', 'SEQUENCE_NO', 'PART_NO')) THEN
            Shop_Ord_Util_API.Record_With_Column_Value_Exist(contract_              => contract_,
                                                             order_no_              => order_no_,
                                                             release_no_            => release_no_,
                                                             sequence_no_           => sequence_no_,
                                                             part_no_               => part_no_,
                                                             eng_chg_level_         => eng_chg_level_,
                                                             activity_seq_          => shopord_activity_seq_,
                                                             condition_code_        => condition_code_,
                                                             component_part_no_     => component_part_no_,
                                                             column_name_           => data_item_id_,
                                                             column_value_          => data_item_value_,
                                                             column_description_    => data_item_description_);
         ELSIF (data_item_id_ IN ('LINE_ITEM_NO','COMPONENT_PART_NO', 'OPERATION_NO')) THEN
            IF (data_item_id_ = 'COMPONENT_PART_NO') THEN
               local_data_item_id_ := 'PART_NO';
            ELSE
               local_data_item_id_ := data_item_id_;
            END IF;
            Shop_Material_Alloc_API.Record_With_Column_Value_Exist(contract_              => contract_,
                                                                   order_no_              => order_no_,
                                                                   release_no_            => release_no_,
                                                                   sequence_no_           => sequence_no_,
                                                                   part_no_               => component_part_no_,
                                                                   line_item_no_          => line_item_no_,
                                                                   activity_seq_          => shopord_activity_seq_,
                                                                   condition_code_        => condition_code_,
                                                                   operation_no_          => operation_no_,
                                                                   column_name_           => local_data_item_id_,
                                                                   column_value_          => data_item_value_,
                                                                   column_description_    => data_item_description_);
         ELSIF (data_item_id_ IN ('CONDITION_CODE')) THEN
            IF (Fnd_Boolean_API.Evaluate_Db(Part_Catalog_API.Serial_Trak_Only_Rece_Issue_Db(component_part_no_)) AND
                Inventory_Part_In_Stock_API.Check_Individual_Exist(component_part_no_, serial_no_) = 0) THEN
               -- Don't use the entered serial no for part in stock validation if the part is only tracked at receipt and issue and not explicitly identified in the inventory.
               serial_no_ := '*';
            END IF;
            -- TODO: Why is condition_code validated against InvPartInStock when its value in automatic/lov comes from Shop_Ord_Util/Shop_Material_Alloc?
            sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
            Inventory_Part_In_Stock_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                       part_no_                    => component_part_no_,
                                                                       configuration_id_           => configuration_id_,
                                                                       location_no_                => location_no_,
                                                                       lot_batch_no_               => lot_batch_no_,
                                                                       serial_no_                  => serial_no_,
                                                                       eng_chg_level_              => eng_chg_level_,
                                                                       waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                       activity_seq_               => activity_seq_,
                                                                       handling_unit_id_           => handling_unit_id_,
                                                                       alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                       column_name_                => data_item_id_,
                                                                       column_value_               => data_item_value_,
                                                                       column_description_         => data_item_description_,
                                                                       sql_where_expression_       => sql_where_expression_,
                                                                       column_value_nullable_      => TRUE);
         ELSIF (data_item_id_ IN ('LOT_BATCH_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO', 'ACTIVITY_SEQ', 'SERIAL_NO', 'LOCATION_NO',
                                  'HANDLING_UNIT_ID', 'SSCC','ALT_HANDLING_UNIT_LABEL_ID')) THEN
            Validate_Data_Item___(contract_, order_no_, release_no_, sequence_no_, line_item_no_, component_part_no_, location_no_,
                                  lot_batch_no_, serial_no_, eng_chg_level_, waiv_dev_rej_no_, configuration_id_, activity_seq_,
                                  handling_unit_id_, alt_handling_unit_label_id_, data_item_id_, data_item_value_, capture_session_id_);
         
         
         ELSIF (data_item_id_ IN ('INPUT_UOM') AND data_item_value_ IS NOT NULL) THEN 
            input_unit_meas_group_id_ := Inventory_Part_API.Get_Input_Unit_Meas_Group_Id(contract_, component_part_no_);
            Input_Unit_Meas_API.Record_With_Column_Value_Exist(input_unit_meas_group_id_ => input_unit_meas_group_id_,
                                                               column_name_              => 'UNIT_CODE',
                                                               column_value_             => data_item_value_,
                                                               column_description_       => data_item_description_,
                                                               sql_where_expression_     => Get_Input_Uom_Sql_Whr_Exprs___); 
         ELSIF (data_item_id_ = 'GTIN') THEN
            session_rec_ := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
            IF (Data_Capture_Config_Detail_API.Get_Enabled_Db(capture_process_id_ => session_rec_.capture_process_id,
                                                              capture_config_id_  => session_rec_.capture_config_id,
                                                              process_detail_id_  => 'GTIN_IS_MANDATORY' ) = Fnd_Boolean_API.DB_TRUE) THEN
               Data_Capture_Session_API.Check_Mandatory_Item_Not_Null(capture_session_id_, 
                                                                      data_item_id_, 
                                                                      data_item_value_, 
                                                                      mandatory_non_process_key_ => TRUE);
            END IF;
            IF (gtin_no_ IS NOT NULL) THEN 
               gtin_part_no_ := Part_Gtin_API.Get_Part_Via_Identified_Gtin(gtin_no_);
               IF (gtin_part_no_ IS NULL) OR ((component_part_no_ IS NOT NULL) AND (component_part_no_ != gtin_part_no_)) THEN               
                  Error_SYS.Record_General(lu_name_, 'VALUENOTEXIST: :P1 :P2 does not exist in the context of the entered data and this process.', data_item_description_, gtin_no_);
               END IF;
               -- Checks above is copy of what is done for GTIN in DataCaptureInventUtil, check below is added for extra GTIN matching the unique record which the above dont handle.
               IF (gtin_part_no_ IS NOT NULL) THEN
                  local_component_part_no_ := Data_Capture_Session_API.Get_Latest_A_If_Before_B(capture_session_id_ => capture_session_id_,
                                                                                                data_item_id_a_     => 'COMPONENT_PART_NO',
                                                                                                data_item_id_b_     => data_item_id_);
                  IF (local_component_part_no_ IS NULL)  THEN
                     local_condition_code_ := Data_Capture_Session_API.Get_Latest_A_If_Before_B(capture_session_id_ => capture_session_id_, 
                                                                                                data_item_id_a_     => 'CONDITION_CODE', 
                                                                                                data_item_id_b_     => data_item_id_);
                     IF (local_condition_code_ IS NULL AND 
                         NOT Data_Capt_Conf_Data_Item_API.Is_A_Before_B(session_rec_.capture_process_id, session_rec_.capture_config_id, 'CONDITION_CODE', data_item_id_)) THEN
                        local_condition_code_ := '%'; 
                     END IF;
                     -- Sending NULL for component_part_no and all items that can be applicable handled and are component_part_no connected
                     -- since these could have gotten their values from the gtin in Get_Filter_Keys___ that might not be correct.
                     -- Since condition_code is nullable we need to use '%' if it hasnt been scanned yet since we cant trust 
                     -- value from Get_Filter_Keys___ since it could be applicable handled using the wrong component_part_no. 
                     local_component_part_no_ := Get_Unique_Data_Item_Value___(contract_            => contract_, 
                                                                               order_no_            => order_no_, 
                                                                               release_no_          => release_no_, 
                                                                               sequence_no_         => sequence_no_, 
                                                                               part_no_             => part_no_, 
                                                                               eng_chg_level_       => eng_chg_level_, 
                                                                               activity_seq_        => activity_seq_, 
                                                                               condition_code_      => local_condition_code_, 
                                                                               waiv_dev_rej_no_     => waiv_dev_rej_no_,
                                                                               component_part_no_   => NULL, 
                                                                               line_item_no_        => line_item_no_, 
                                                                               operation_no_        => operation_no_,
                                                                               location_no_         => location_no_, 
                                                                               lot_batch_no_        => NULL, 
                                                                               serial_no_           => NULL, 
                                                                               handling_unit_id_    => handling_unit_id_, 
                                                                               alt_handling_unit_label_id_ => alt_handling_unit_label_id_, 
                                                                               barcode_id_          => barcode_id_, 
                                                                               wanted_data_item_id_ => 'COMPONENT_PART_NO');
                  END IF;
                  IF (local_component_part_no_ IS NOT NULL AND gtin_part_no_ != local_component_part_no_)  THEN
                     -- This error is needed, since the part taken from GTIN dont match the already scanned part or the part that the unique record points to.
                     Error_SYS.Record_General(lu_name_, 'GTINDONTMATCH: The GTIN No does not match current Shop Order Material.');
                  END IF;
               END IF;
            END IF;
         ELSIF (data_item_id_ LIKE 'GS1%') THEN
            Data_Capture_Invent_Util_API.Validate_Gs1_Data_Item(capture_session_id_, data_item_id_, data_item_value_);      
         ELSE
            -- NOTE: Validate all data items not avaliable in the check valid value method
            IF (data_item_id_ IN ('QUANTITY')) THEN
               Data_Capture_Shopord_Util_API.Validate_Data_Item(capture_session_id_,
                                                               data_item_id_,
                                                               data_item_value_);
            ELSIF (data_item_id_ = 'BARCODE_ID') THEN
               Data_Capture_Invent_Util_API.Validate_Data_Item(capture_session_id_,
                                                               data_item_id_,
                                                               data_item_value_);
               IF (data_item_value_ IS NOT NULL) THEN
                  data_item_description_ := Data_Capt_Proc_Data_Item_API.Get_Description(Data_Capture_Session_API.Get_Capture_Process_Id(capture_session_id_), data_item_id_);
                  Inventory_Part_Barcode_API.Record_With_Column_Value_Exist(contract_           => contract_,
                                                                            barcode_id_         => data_item_value_,
                                                                            part_no_            => component_part_no_,   -- component_part_no_ used here
                                                                            configuration_id_   => configuration_id_,
                                                                            lot_batch_no_       => lot_batch_no_,
                                                                            serial_no_          => serial_no_,
                                                                            eng_chg_level_      => eng_chg_level_,
                                                                            waiv_dev_rej_no_    => waiv_dev_rej_no_,
                                                                            activity_seq_       => activity_seq_,
                                                                            column_name_        => data_item_id_,
                                                                            column_value_       => data_item_value_,
                                                                            column_description_ => data_item_description_);
               END IF;
            ELSE
               Data_Capture_Invent_Util_API.Validate_Data_Item(capture_session_id_,
                                                               data_item_id_,
                                                               data_item_value_);
            END IF;
         END IF;
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Validate_Data_Item');
   Core(capture_session_id_, data_item_id_, data_item_value_);
END Validate_Data_Item;


PROCEDURE Create_List_Of_Values (
   capture_session_id_  IN NUMBER,
   capture_process_id_  IN VARCHAR2,
   capture_config_id_   IN NUMBER,
   data_item_id_        IN VARCHAR2,
   contract_            IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      capture_session_id_  IN NUMBER,
      capture_process_id_  IN VARCHAR2,
      capture_config_id_   IN NUMBER,
      data_item_id_        IN VARCHAR2,
      contract_            IN VARCHAR2 )
   IS
      dummy_contract_             VARCHAR2(5);
      serial_no_                  VARCHAR2(50);
      order_no_                   VARCHAR2(12);
      release_no_                 VARCHAR2(4);
      sequence_no_                VARCHAR2(4);
      part_no_                    VARCHAR2(25);
      component_part_no_          VARCHAR2(25);
      lot_batch_no_               VARCHAR2(20);
      eng_chg_level_              VARCHAR2(6);
      waiv_dev_rej_no_            VARCHAR2(15);
      activity_seq_               NUMBER;
      shopord_activity_seq_       NUMBER;
      condition_code_             VARCHAR2(10);
      line_item_no_               NUMBER;
      operation_no_               NUMBER;
      location_no_                VARCHAR2(35);
      part_in_stock_serial_no_    VARCHAR2(50);
      local_data_item_id_         VARCHAR2(50);
      barcode_id_                 NUMBER;
      qty_reserved_               NUMBER;
      configuration_id_           VARCHAR2(50);
      sql_where_expression_       VARCHAR2(2000);
      handling_unit_id_           NUMBER;
      sscc_                       VARCHAR2(18);
      alt_handling_unit_label_id_ VARCHAR2(25);
      lov_type_db_                VARCHAR2(20);
      input_uom_group_id_         VARCHAR2(30);
      gtin_no_                    VARCHAR2(14);
      -- Bug 145218, start
      customer_no_                VARCHAR2(20);
      -- Bug 145218, end
   BEGIN
      IF (data_item_id_ IN ('BARCODE_ID', 'LOCATION_NO')) THEN
         -- We need a complete set of filter keys fetched with unique handling so we can find a possible unique barcode and filter it correctly
         Get_Filter_Keys___(dummy_contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                            component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                            handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_,
                            data_item_value_ => NULL, use_unique_values_ => TRUE);
      ELSE
         Get_Filter_Keys___(dummy_contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                            component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                            handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_);
      END IF;
      
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         lov_type_db_ := Data_Capt_Conf_Data_Item_API.Get_List_Of_Values_Db(capture_process_id_, capture_config_id_, data_item_id_);
      $END
   
      -- NOTE: If the part is receipt and issue tracked, but not tracked in inventory, the serial no should not be used in lovfilter
      IF (Part_Catalog_API.Serial_Tracked_Only_Rece_Issue(component_part_no_) AND
         NOT Fnd_Boolean_API.Is_True_Db(Part_Serial_Catalog_API.Get_Tracked_In_Inventory_Db(component_part_no_, serial_no_))) THEN
         part_in_stock_serial_no_ := NULL;
      ELSE
         part_in_stock_serial_no_ := serial_no_;
      END IF;
      IF (activity_seq_ = 0) THEN
         shopord_activity_seq_ := NULL;  -- shop_ord have NULL instead of 0 for non project parts
      ELSE
         shopord_activity_seq_ := activity_seq_;
      END IF;
      configuration_id_ := NVL(Shop_Material_Alloc_API.Get_Configuration_Id(order_no_, release_no_, sequence_no_, line_item_no_), '*');
   
      IF (data_item_id_ = 'BARCODE_ID' OR
          (barcode_id_ IS NOT NULL AND data_item_id_ IN ('COMPONENT_PART_NO', 'LOT_BATCH_NO', 'SERIAL_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO', 'ACTIVITY_SEQ'))) THEN
         IF (data_item_id_ = 'COMPONENT_PART_NO') THEN
            local_data_item_id_ := 'PART_NO';
         ELSE
            local_data_item_id_ := data_item_id_;
         END IF;
         Inventory_Part_Barcode_API.Create_Data_Capture_Lov(contract_           => contract_,
                                                            barcode_id_         => barcode_id_,
                                                            part_no_            => component_part_no_,
                                                            configuration_id_   => configuration_id_,
                                                            lot_batch_no_       => lot_batch_no_,
                                                            serial_no_          => part_in_stock_serial_no_,
                                                            eng_chg_level_      => eng_chg_level_,
                                                            waiv_dev_rej_no_    => waiv_dev_rej_no_,
                                                            activity_seq_       => activity_seq_,
                                                            capture_session_id_ => capture_session_id_,
                                                            column_name_        => local_data_item_id_,
                                                            lov_type_db_        => lov_type_db_);
   
      ELSIF (data_item_id_ IN ('LINE_ITEM_NO', 'CONDITION_CODE', 'COMPONENT_PART_NO', 'OPERATION_NO')) THEN
         IF (data_item_id_ = 'COMPONENT_PART_NO') THEN
            local_data_item_id_ := 'PART_NO';
         ELSE
            local_data_item_id_ := data_item_id_;
         END IF;
         Shop_Material_Alloc_API.Create_Data_Capture_Lov(contract_              => contract_,
                                                         order_no_              => order_no_,
                                                         release_no_            => release_no_,
                                                         sequence_no_           => sequence_no_,
                                                         part_no_               => component_part_no_,
                                                         line_item_no_          => line_item_no_,
                                                         activity_seq_          => shopord_activity_seq_,
                                                         condition_code_        => condition_code_,
                                                         operation_no_          => operation_no_,
                                                         capture_session_id_    => capture_session_id_,
                                                         column_name_           => local_data_item_id_,
                                                         lov_type_db_           => lov_type_db_,
                                                         lov_id_                => 1);
      ELSIF (data_item_id_ IN ('ORDER_NO','RELEASE_NO', 'SEQUENCE_NO', 'PART_NO')) THEN    
         
         Shop_Ord_Util_API.Create_Data_Capture_Lov(contract_              => contract_,
                                                   order_no_              => order_no_,
                                                   release_no_            => release_no_,
                                                   sequence_no_           => sequence_no_,
                                                   part_no_               => part_no_,
                                                   eng_chg_level_         => eng_chg_level_,
                                                   activity_seq_          => shopord_activity_seq_,
                                                   condition_code_        => condition_code_,
                                                   lot_batch_no_          => NULL,
                                                   component_part_no_     => component_part_no_,
                                                   capture_session_id_    => capture_session_id_,
                                                   column_name_           => data_item_id_,
                                                   lov_type_db_           => lov_type_db_,
                                                   lov_id_                => 4);
      ELSIF (data_item_id_ IN ('INPUT_UOM')) THEN  
         input_uom_group_id_ := Inventory_Part_API.Get_Input_Unit_Meas_Group_Id(contract_, component_part_no_);
         Input_Unit_Meas_API.Create_Data_Capture_Lov(capture_session_id_, input_uom_group_id_, 'UNIT_CODE', lov_type_db_, Get_Input_Uom_Sql_Whr_Exprs___);   
      ELSIF (data_item_id_ IN ('SERIAL_NO','LOCATION_NO','LOT_BATCH_NO','WAIV_DEV_REJ_NO','ENG_CHG_LEVEL','ACTIVITY_SEQ',
                               'HANDLING_UNIT_ID', 'SSCC','ALT_HANDLING_UNIT_LABEL_ID')) THEN
         qty_reserved_ := Shop_Material_Alloc_API.Get_Qty_Assigned(order_no_, release_no_, sequence_no_, line_item_no_);
         -- Serial tracked in inventory or not serial tracked at all.
         IF (((Part_Catalog_API.Get_Serial_Tracking_Code_Db(component_part_no_) = Part_Serial_Tracking_API.DB_SERIAL_TRACKING OR
             Part_Catalog_API.Get_Rcpt_Issue_Serial_Track_Db(component_part_no_) = Fnd_Boolean_API.DB_FALSE)) OR
             data_item_id_ IN ('LOCATION_NO','LOT_BATCH_NO','WAIV_DEV_REJ_NO','ENG_CHG_LEVEL','ACTIVITY_SEQ',
                               'HANDLING_UNIT_ID', 'SSCC','ALT_HANDLING_UNIT_LABEL_ID')) THEN
            IF (qty_reserved_ > 0) THEN
               -- If any qty is reserved for the material line -> show only reserved serial no's or locations from inventory part in stock reservation
               -- since it is only allowed to issue the exact reservation if reservations exist.
               Inv_Part_Stock_Reservation_API.Create_Data_Capture_Lov(contract_                   => contract_,
                                                                      order_no_                   => order_no_,
                                                                      line_no_                    => release_no_,
                                                                      release_no_                 => sequence_no_,
                                                                      line_item_no_               => line_item_no_,
                                                                      part_no_                    => component_part_no_,
                                                                      configuration_id_           => configuration_id_,
                                                                      location_no_                => location_no_,
                                                                      lot_batch_no_               => lot_batch_no_,
                                                                      serial_no_                  => part_in_stock_serial_no_,
                                                                      eng_chg_level_              => eng_chg_level_,
                                                                      waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                      activity_seq_               => activity_seq_,
                                                                      handling_unit_id_           => handling_unit_id_,
                                                                      alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                      capture_session_id_         => capture_session_id_,
                                                                      column_name_                => data_item_id_,
                                                                      lov_type_db_                => lov_type_db_);
            ELSE
               sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
               Inventory_Part_In_Stock_API.Create_Data_Capture_Lov(contract_                   => contract_,
                                                                   part_no_                    => component_part_no_,
                                                                   configuration_id_           => configuration_id_,
                                                                   location_no_                => location_no_,
                                                                   lot_batch_no_               => lot_batch_no_,
                                                                   serial_no_                  => part_in_stock_serial_no_,
                                                                   eng_chg_level_              => eng_chg_level_,
                                                                   waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                   activity_seq_               => activity_seq_,
                                                                   handling_unit_id_           => handling_unit_id_,
                                                                   alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                   capture_session_id_         => capture_session_id_,
                                                                   column_name_                => data_item_id_,
                                                                   lov_type_db_                => lov_type_db_,
                                                                   sql_where_expression_       => sql_where_expression_);
            END IF;
         ELSIF (Part_Catalog_API.Serial_Tracked_Only_Rece_Issue(component_part_no_) AND data_item_id_ = 'SERIAL_NO') THEN
            -- Bug 145218, start
               customer_no_ := Shop_Material_Alloc_API.Get_Owning_Customer_No(order_no_, release_no_, sequence_no_, line_item_no_);
            -- Bug 145218, end
            -- Bug 145218, Passed owner_ as a method parameter.
            Temporary_Part_Tracking_API.Create_Data_Capture_Lov(contract_           => contract_,
                                                                part_no_            => component_part_no_,
                                                                serial_no_          => NULL,
                                                                lot_batch_no_       => lot_batch_no_,
                                                                configuration_id_   => configuration_id_,
                                                                capture_session_id_ => capture_session_id_,
                                                                column_name_        => data_item_id_,
                                                                lov_type_db_        => lov_type_db_,
                                                                customer_no_        => customer_no_);
            sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_, unique_type_ => 'SERIAL_TRACKED_ONLY_RECE_ISSUE');
            Inventory_Part_In_Stock_API.Create_Data_Capture_Lov(contract_                   => contract_,
                                                                part_no_                    => component_part_no_,
                                                                configuration_id_           => configuration_id_,
                                                                location_no_                => location_no_,
                                                                lot_batch_no_               => lot_batch_no_,
                                                                serial_no_                  => NULL,
                                                                eng_chg_level_              => eng_chg_level_,
                                                                waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                activity_seq_               => activity_seq_,
                                                                handling_unit_id_           => handling_unit_id_,
                                                                alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                capture_session_id_         => capture_session_id_,
                                                                column_name_                => data_item_id_,
                                                                lov_type_db_                => lov_type_db_,
                                                                sql_where_expression_       => sql_where_expression_);
         END IF;
      END IF;
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Create_List_Of_Values');
   Core(capture_session_id_, capture_process_id_, capture_config_id_, data_item_id_, contract_);
END Create_List_Of_Values;


--@IgnoreMissingSysinit
FUNCTION Get_Process_Execution_Message (
   capture_process_id_    IN VARCHAR2,
   no_of_records_handled_ IN NUMBER,
   process_message_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   
   FUNCTION Core (
      capture_process_id_    IN VARCHAR2,
      no_of_records_handled_ IN NUMBER,
      process_message_       IN VARCHAR2 ) RETURN VARCHAR2
   IS
      message_               VARCHAR2(200);
   BEGIN
      message_ :=  Language_SYS.Translate_Constant(lu_name_, 'ISSUEMATR: The shop order material was issued.');
      RETURN message_;
   END Core;

BEGIN
   RETURN Core(capture_process_id_, no_of_records_handled_, process_message_);
END Get_Process_Execution_Message;


FUNCTION Get_Automatic_Data_Item_Value (
   capture_session_id_ IN VARCHAR2,
   data_item_id_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   
   FUNCTION Core (
      capture_session_id_ IN VARCHAR2,
      data_item_id_       IN VARCHAR2 ) RETURN VARCHAR2
   IS
      contract_                     VARCHAR2(5);
      part_no_                      VARCHAR2(25);
      component_part_no_            VARCHAR2(25);
      order_no_                     VARCHAR2(12);
      release_no_                   VARCHAR2(4);
      sequence_no_                  VARCHAR2(4);
      eng_chg_level_                VARCHAR2(6);
      lot_batch_no_                 VARCHAR2(20);
      activity_seq_                 NUMBER;
      condition_code_               VARCHAR2(10);
      location_no_                  VARCHAR2(35);
      line_item_no_                 NUMBER;
      operation_no_                 NUMBER;
      serial_no_                    VARCHAR2(50);
      waiv_dev_rej_no_              VARCHAR2(15);
      barcode_id_                   NUMBER;
      automatic_value_              VARCHAR2(200);
      qty_assigned_                 NUMBER;
      handling_unit_id_             NUMBER;
      sscc_                         VARCHAR2(18);
      alt_handling_unit_label_id_   VARCHAR2(25);
      qty_on_hand_                  NUMBER;
      qty_reserved_                 NUMBER;
      qty_available_                NUMBER;
      qty_to_be_issued_             NUMBER;
      shopord_activity_seq_         NUMBER;
      local_data_item_id_           VARCHAR2(50);
      configuration_id_             VARCHAR2(50);
      sql_where_expression_         VARCHAR2(2000);
      dummy_                        BOOLEAN;
      gtin_no_                      VARCHAR2(14);
      input_uom_                    VARCHAR2(30);
      input_uom_group_id_           VARCHAR2(30);
      input_qty_                    NUMBER;
      input_conv_factor_            NUMBER;
      session_rec_                  Data_Capture_Common_Util_API.Session_Rec;
      invepart_rec_                 Inventory_Part_API.Public_Rec;
      
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         session_rec_ := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
         -- Try and get value from any previously scanned GS1 barcode if this data item have AI code connected to them. Also reducing the value to lengths we have on the IFS objects
         automatic_value_ := SUBSTR(Data_Capture_Session_API.Get_Item_Value_From_Gs1_Items(capture_session_id_ => capture_session_id_,
                                                                                           capture_process_id_ => session_rec_.capture_process_id,
                                                                                           capture_config_id_  => session_rec_.capture_config_id,
                                                                                           data_item_id_       => data_item_id_), 1, 
                                    NVL(Data_Capt_Proc_Data_Item_API.Get_String_Length(session_rec_.capture_process_id, data_item_id_), 200));
      
         IF (automatic_value_ IS NULL) THEN
   
            IF (data_item_id_ IN ('BARCODE_ID', 'QUANTITY')) THEN
               -- We need a complete set of filter keys fetched with unique handling so we can find a possible unique barcode and filter it correctly
               Get_Filter_Keys___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                  component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                                  handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_,
                                  data_item_value_ => NULL, use_unique_values_ => TRUE);
            ELSE
               Get_Filter_Keys___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                  component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                                  handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_);
            END IF;
      
            IF (data_item_id_ = 'BARCODE_ID') THEN
               automatic_value_ :=  barcode_id_;
            ELSIF (data_item_id_ IN ('COMPONENT_PART_NO', 'LOT_BATCH_NO', 'SERIAL_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO', 'ACTIVITY_SEQ',
                                     'ORDER_NO','RELEASE_NO','SEQUENCE_NO', 'PART_NO', 'LINE_ITEM_NO', 'LOCATION_NO', 'HANDLING_UNIT_ID', 
                                     'SSCC','ALT_HANDLING_UNIT_LABEL_ID', 'CONDITION_CODE', 'OPERATION_NO')) THEN
               IF (Part_Catalog_API.Serial_Tracked_Only_Rece_Issue(component_part_no_) AND
                   NOT Fnd_Boolean_API.Is_True_Db(Part_Serial_Catalog_API.Get_Tracked_In_Inventory_Db(component_part_no_, serial_no_))) THEN
                  serial_no_ := '*';
               END IF;
      
               -- NOTE: For future refactoring/bug fixing we might have to change shopord_activity_seq_ handling here. Since now we can't see the difference between if the value actually is NULL
               -- or because ACTIVITY_SEQ comes after current data item in the configuration. It might be better to set it to '%' or -1 and change
               -- Shop_Ord_Util_API.Get_Column_Value_If_Unique/Shop_Material_Alloc_API.Get_Column_Value_If_Unique to handle %/-1 for shopord_activity_seq_.
               IF (activity_seq_ = 0) THEN
                  shopord_activity_seq_ := NULL;  -- shop_ord have NULL instead of 0 for non project parts
               ELSE
                  shopord_activity_seq_ := activity_seq_;
               END IF;
      
               configuration_id_ := NVL(Shop_Material_Alloc_API.Get_Configuration_Id(order_no_, release_no_, sequence_no_, line_item_no_), '*');
      
               IF (barcode_id_ IS NOT NULL AND
                   data_item_id_ IN ('COMPONENT_PART_NO', 'LOT_BATCH_NO', 'SERIAL_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO', 'ACTIVITY_SEQ')) THEN
      
                  IF (data_item_id_ = 'COMPONENT_PART_NO') THEN
                     local_data_item_id_ := 'PART_NO';
                  ELSE
                     local_data_item_id_ := data_item_id_;
                  END IF;
                  automatic_value_ := Inventory_Part_Barcode_API.Get_Column_Value_If_Unique(contract_         => contract_,
                                                                                            barcode_id_       => barcode_id_,
                                                                                            part_no_          => component_part_no_,
                                                                                            configuration_id_ => configuration_id_,
                                                                                            lot_batch_no_     => lot_batch_no_,
                                                                                            serial_no_        => serial_no_,
                                                                                            eng_chg_level_    => eng_chg_level_,
                                                                                            waiv_dev_rej_no_  => waiv_dev_rej_no_,
                                                                                            activity_seq_     => activity_seq_,
                                                                                            column_name_      => local_data_item_id_ );
                  IF (data_item_id_ = 'SERIAL_NO' AND
                      Part_Catalog_API.Get_Rcpt_Issue_Serial_Track_Db(component_part_no_) = Fnd_Boolean_API.DB_TRUE AND
                      Part_Catalog_API.Get_Serial_Tracking_Code_Db(component_part_no_) = Part_Serial_Tracking_API.DB_NOT_SERIAL_TRACKING AND
                      Inventory_Part_Barcode_API.Get_Serial_No(contract_, barcode_id_) = '*') THEN
                        automatic_value_ := NULL;
                  END IF;
               ELSIF (data_item_id_ IN ('ORDER_NO','RELEASE_NO','SEQUENCE_NO', 'PART_NO')) THEN  
                  IF automatic_value_ IS NULL THEN
                     automatic_value_ := Shop_Ord_Util_API.Get_Column_Value_If_Unique(contract_              => contract_,
                                                                                    order_no_              => order_no_,
                                                                                    release_no_            => release_no_,
                                                                                    sequence_no_           => sequence_no_,
                                                                                    part_no_               => part_no_,
                                                                                    eng_chg_level_         => eng_chg_level_,
                                                                                    activity_seq_          => shopord_activity_seq_,
                                                                                    condition_code_        => condition_code_,
                                                                                    lot_batch_no_          => NULL,
                                                                                    column_name_           => data_item_id_);
                  END IF;

                                                                                    
               ELSIF (data_item_id_ IN ('LOT_BATCH_NO','SERIAL_NO','WAIV_DEV_REJ_NO','ACTIVITY_SEQ', 'ENG_CHG_LEVEL', 'LOCATION_NO',
                                        'HANDLING_UNIT_ID', 'SSCC', 'ALT_HANDLING_UNIT_LABEL_ID')) THEN
      
                  sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
                  automatic_value_ := Inventory_Part_In_Stock_API.Get_Column_Value_If_Unique(no_unique_value_found_      => dummy_,
                                                                                             contract_                   => contract_,
                                                                                             part_no_                    => component_part_no_,
                                                                                             location_no_                => location_no_,
                                                                                             eng_chg_level_              => eng_chg_level_,
                                                                                             activity_seq_               => activity_seq_,
                                                                                             lot_batch_no_               => lot_batch_no_,
                                                                                             serial_no_                  => serial_no_,
                                                                                             configuration_id_           => configuration_id_,
                                                                                             waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                                             handling_unit_id_           => handling_unit_id_,
                                                                                             alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                                             column_name_                => data_item_id_,
                                                                                             sql_where_expression_       => sql_where_expression_);
      
               ELSIF (data_item_id_ IN ('COMPONENT_PART_NO','LINE_ITEM_NO', 'CONDITION_CODE', 'OPERATION_NO')) THEN
                  IF (data_item_id_ = 'COMPONENT_PART_NO') THEN
                     local_data_item_id_ := 'PART_NO';
                  ELSE
                     local_data_item_id_ := data_item_id_;
                  END IF;
                  automatic_value_ := Shop_Material_Alloc_API.Get_Column_Value_If_Unique(contract_              => contract_,
                                                                                         order_no_              => order_no_,
                                                                                         release_no_            => release_no_,
                                                                                         sequence_no_           => sequence_no_,
                                                                                         part_no_               => component_part_no_,
                                                                                         line_item_no_          => line_item_no_,
                                                                                         activity_seq_          => shopord_activity_seq_,
                                                                                         condition_code_        => condition_code_,
                                                                                         operation_no_          => operation_no_,
                                                                                         column_name_           => local_data_item_id_);  
      
               END IF;  
            ELSIF (data_item_id_= 'INPUT_UOM') THEN
               input_uom_group_id_ := Inventory_Part_API.Get_Input_Unit_Meas_Group_Id(contract_, component_part_no_);
               IF (input_uom_group_id_ IS NOT NULL) THEN
                  IF (gtin_no_ IS NOT NULL) THEN
                     automatic_value_ := Part_Gtin_Unit_Meas_API.Get_Unit_Code_For_Gtin14(gtin_no_);              
                  END IF;
                  IF (automatic_value_ IS NULL) THEN               
                     automatic_value_ := Input_Unit_Meas_API.Get_Column_Value_If_Unique(input_unit_meas_group_id_ => input_uom_group_id_,
                                                                                        column_name_              => 'UNIT_CODE',
                                                                                        sql_where_expression_     => Get_Input_Uom_Sql_Whr_Exprs___);
                  END IF;
               ELSE
                  automatic_value_ := 'NULL';
               END IF;   
            ELSIF (data_item_id_= 'INPUT_QUANTITY') THEN
               input_uom_ := Data_Capture_Session_API.Get_Latest_A_If_Before_B(capture_session_id_ => capture_session_id_,
                                                                               data_item_id_a_     => 'INPUT_UOM',
                                                                               data_item_id_b_     => data_item_id_);
               IF ((input_uom_ IS NULL) AND Data_Capt_Conf_Data_Item_API.Is_A_Before_B(session_rec_.capture_process_id, session_rec_.capture_config_id, 'INPUT_UOM', 'INPUT_QUANTITY'))
                   OR (Inventory_Part_API.Get_Input_Unit_Meas_Group_Id(contract_, component_part_no_) IS NULL) THEN            
                  automatic_value_ := 'NULL';                     
               END IF;  
            ELSIF (data_item_id_= 'GTIN') THEN         
               automatic_value_ := Part_Gtin_API.Get_Default_Gtin_No(component_part_no_);
               IF (component_part_no_ IS NOT NULL AND automatic_value_ IS NULL) THEN            
                  automatic_value_ := 'NULL';                     
               END IF;
            ELSIF (data_item_id_ = 'EXPIRATION_DATE') THEN
               invepart_rec_ := Inventory_Part_API.Get(contract_, part_no_);
   
               IF ((invepart_rec_.durability_day IS NOT NULL) AND (invepart_rec_.mandatory_expiration_date = Fnd_Boolean_API.DB_TRUE)) THEN  
                  automatic_value_ := TO_CHAR(Site_API.Get_Site_Date(contract_) + invepart_rec_.durability_day, Client_SYS.date_format_);
               ELSE
                  automatic_value_ := 'NULL';
               END IF;
            ELSIF (data_item_id_ = 'SERIAL_NO') THEN
               IF (Part_Catalog_API.Get_Receipt_Issue_Serial_Tr_Db(part_no_) = Fnd_Boolean_API.DB_FALSE) THEN
                  automatic_value_ := '*';
               ELSE
                  automatic_value_ := NULL;
               END IF;
            ELSIF (data_item_id_ = 'ORIGIN_PACK_SIZE') THEN
               automatic_value_ := NULL;
            ELSIF (data_item_id_ = 'QUANTITY') THEN
               IF ((order_no_ IS NOT NULL) AND (release_no_ IS NOT NULL) AND (sequence_no_ IS NOT NULL) AND (line_item_no_ IS NOT NULL)
                   AND (contract_ IS NOT NULL) AND (component_part_no_ IS NOT NULL) AND (location_no_ IS NOT NULL) AND (lot_batch_no_ IS NOT NULL)
                   AND (serial_no_ IS NOT NULL) AND (eng_chg_level_ IS NOT NULL) AND (waiv_dev_rej_no_ IS NOT NULL) AND (activity_seq_ IS NOT NULL)) THEN
   
                  input_uom_ := Data_Capture_Session_API.Get_Latest_A_If_Before_B(capture_session_id_ => capture_session_id_, 
                                                                                  data_item_id_a_     => 'INPUT_UOM',
                                                                                  data_item_id_b_     => data_item_id_);
   
                  input_qty_ := Data_Capture_Session_API.Get_Latest_A_If_Before_B(capture_session_id_ => capture_session_id_, 
                                                                                  data_item_id_a_     => 'INPUT_QUANTITY',
                                                                                  data_item_id_b_     => data_item_id_);
                  IF (input_uom_ IS NOT NULL) AND (input_qty_ IS NOT NULL) THEN
                     input_uom_group_id_ := Inventory_Part_API.Get_Input_Unit_Meas_Group_Id(contract_, component_part_no_);
                     input_conv_factor_ := Input_Unit_Meas_API.Get_Conversion_Factor(input_uom_group_id_, input_uom_);
                     automatic_value_ := input_qty_ * input_conv_factor_;
   
                  ELSE   
                     qty_assigned_ := Shop_Material_Assign_API.Get_Qty_Assigned(order_no_, release_no_, sequence_no_, line_item_no_,contract_,component_part_no_,
                                                              location_no_, lot_batch_no_, serial_no_, eng_chg_level_, waiv_dev_rej_no_, '*', activity_seq_, handling_unit_id_);
   
                     -- Note: When qty is reserved then qty_assigned_ is defaulted, else remaining required qty will be defaulted.
                     --       But if the available qty is less than remaining required qty then available qty will be defaulted.
                     IF (NVL(qty_assigned_, 0) = 0) THEN
                        qty_to_be_issued_ := Shop_Material_Alloc_API.Get_Qty_Remaining_To_Issue(order_no_, release_no_, sequence_no_, line_item_no_);
   
                        qty_on_hand_ := Inventory_Part_In_Stock_API.Get_Qty_Onhand(contract_         => contract_,
                                                                                   part_no_          => component_part_no_,
                                                                                   configuration_id_ => '*',
                                                                                   location_no_      => location_no_,
                                                                                   lot_batch_no_     => lot_batch_no_,
                                                                                   serial_no_        => serial_no_,
                                                                                   eng_chg_level_    => eng_chg_level_,
                                                                                   waiv_dev_rej_no_  => waiv_dev_rej_no_,
                                                                                   activity_seq_     => activity_seq_,
                                                                                   handling_unit_id_ => handling_unit_id_);
   
                        qty_reserved_ := Inventory_Part_In_Stock_API.Get_Qty_Reserved(contract_         => contract_,
                                                                                      part_no_          => component_part_no_,
                                                                                      configuration_id_ => '*',
                                                                                      location_no_      => location_no_,
                                                                                      lot_batch_no_     => lot_batch_no_,
                                                                                      serial_no_        => serial_no_,
                                                                                      eng_chg_level_    => eng_chg_level_,
                                                                                      waiv_dev_rej_no_  => waiv_dev_rej_no_,
                                                                                      activity_seq_     => activity_seq_,
                                                                                      handling_unit_id_ => handling_unit_id_);
                        qty_available_ := qty_on_hand_ - qty_reserved_;
                        -- Note: When the available qty is less than the required qty then the system will defualt the available qty.
                        IF (qty_available_ < qty_to_be_issued_) THEN
                           qty_to_be_issued_ := qty_available_;
                        END IF;
                     ELSE
                       qty_to_be_issued_ := qty_assigned_;
                     END IF;
   
                     IF (qty_to_be_issued_ < 0) THEN
                        qty_to_be_issued_ := 0;
                     END IF;
                     automatic_value_ := qty_to_be_issued_;
                  END IF;
               END IF;
            ELSIF (data_item_id_ = 'COMPONENT_SERIAL_NO') THEN
               automatic_value_ := serial_no_;
            ELSIF (data_item_id_ = 'COMPONENT_LOT_BATCH_NO') THEN
               automatic_value_ := lot_batch_no_;
            ELSIF (data_item_id_ = 'COMPONENT_WAIV_DEV_REJ_NO') THEN
               automatic_value_ := SERIAL_NO_RESERV_STRUCT_API.Get_Waiv_Dev_Rej (part_no_, serial_no_, lot_batch_no_);
            ELSE
               automatic_value_ := Data_Capture_Invent_Util_API.Get_Automatic_Data_Item_Value(data_item_id_, contract_, part_no_);
            END IF;
         END IF;
   
         RETURN automatic_value_;
      $ELSE
         RETURN NULL;
      $END
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Get_Automatic_Data_Item_Value');
   RETURN Core(capture_session_id_, data_item_id_);
END Get_Automatic_Data_Item_Value;


PROCEDURE Set_Media_Id_For_Data_Item  (
   capture_session_id_  IN NUMBER,
   line_no_             IN NUMBER,
   data_item_id_        IN VARCHAR2,
   data_item_value_     IN VARCHAR2 )
IS
   
   PROCEDURE Core  (
      capture_session_id_  IN NUMBER,
      line_no_             IN NUMBER,
      data_item_id_        IN VARCHAR2,
      data_item_value_     IN VARCHAR2 )
   IS
   BEGIN
      Data_Capture_Invent_Util_API.Set_Media_Id_For_Data_Item (capture_session_id_, line_no_, data_item_id_, data_item_value_);
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Set_Media_Id_For_Data_Item');
   Core(capture_session_id_, line_no_, data_item_id_, data_item_value_);
END Set_Media_Id_For_Data_Item;


PROCEDURE Add_Details_For_Latest_Item (
   capture_session_id_      IN NUMBER,
   latest_data_item_id_     IN VARCHAR2,
   latest_data_item_value_  IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      capture_session_id_      IN NUMBER,
      latest_data_item_id_     IN VARCHAR2,
      latest_data_item_value_  IN VARCHAR2 )
   IS
      session_rec_                  Data_Capture_Common_Util_API.Session_Rec;
      conf_item_detail_tab_         Data_Capture_Common_Util_API.Config_Item_Detail_Tab;
      contract_                     VARCHAR2(5);
      part_no_                      VARCHAR2(25);
      component_part_no_            VARCHAR2(25);
      order_no_                     VARCHAR2(12);
      release_no_                   VARCHAR2(4);
      sequence_no_                  VARCHAR2(4);
      eng_chg_level_                VARCHAR2(6);
      lot_batch_no_                 VARCHAR2(20);
      activity_seq_                 NUMBER;
      condition_code_               VARCHAR2(10);
      location_no_                  VARCHAR2(35);
      line_item_no_                 NUMBER;
      operation_no_                 NUMBER;
      serial_no_                    VARCHAR2(50);
      waiv_dev_rej_no_              VARCHAR2(15);
      barcode_id_                   NUMBER;
      configuration_id_             VARCHAR2(50);
      handling_unit_id_             NUMBER;
      sscc_                         VARCHAR2(18);
      alt_handling_unit_label_id_   VARCHAR2(25);
      gtin_no_                      VARCHAR2(14);  
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         -- Fetch all necessary keys for all possible detail items below
         session_rec_          := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
         Get_Filter_Keys___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                            component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                            handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, latest_data_item_id_,
                            latest_data_item_value_, use_unique_values_ => TRUE);
   
         configuration_id_ := NVL(Shop_Material_Alloc_API.Get_Configuration_Id(order_no_, release_no_, sequence_no_, line_item_no_), '*');
   
         -- fetch the detail items collection
         conf_item_detail_tab_ := Data_Capt_Conf_Item_Detail_API.Get_Collection(capture_process_id_ => session_rec_.capture_process_id,
                                                                                capture_config_id_  => session_rec_.capture_config_id,
                                                                                data_item_id_       => latest_data_item_id_ );
   
         IF (conf_item_detail_tab_.COUNT > 0) THEN
            FOR i IN conf_item_detail_tab_.FIRST..conf_item_detail_tab_.LAST LOOP
   
               -- DATA ITEMS AS DETAILS
               IF (conf_item_detail_tab_(i).item_type = Capture_Session_Item_Type_API.DB_DATA) THEN
                  IF (conf_item_detail_tab_(i).data_item_detail_id IN ('COMPONENT_PART_NO', 'LOT_BATCH_NO', 'SERIAL_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO',
                                                                       'ACTIVITY_SEQ', 'ORDER_NO','RELEASE_NO','SEQUENCE_NO', 'PART_NO', 'LINE_ITEM_NO',
                                                                       'LOCATION_NO', 'BARCODE_ID', 'CONDITION_CODE', 'HANDLING_UNIT_ID', 'SSCC',
                                                                       'ALT_HANDLING_UNIT_LABEL_ID', 'OPERATION_NO', 'GTIN')) THEN
   
                     condition_code_ := CASE condition_code_ WHEN '%' THEN NULL ELSE condition_code_ END;      -- % if it is not scanned yet
                     alt_handling_unit_label_id_ := CASE alt_handling_unit_label_id_ WHEN '%' THEN NULL ELSE alt_handling_unit_label_id_ END;      -- % if it is not scanned yet
                     operation_no_ := CASE operation_no_ WHEN -1 THEN NULL ELSE operation_no_ END;      -- -1 if it is not scanned yet
                     -- Data Items that are part of the filter keys
                     Add_Filter_Key_Detail___(capture_session_id_         => capture_session_id_,
                                              owning_data_item_id_        => latest_data_item_id_,
                                              data_item_detail_id_        => conf_item_detail_tab_(i).data_item_detail_id,
                                              order_no_                   => order_no_,
                                              release_no_                 => release_no_,
                                              sequence_no_                => sequence_no_,
                                              part_no_                    => part_no_,
                                              eng_chg_level_              => eng_chg_level_,
                                              activity_seq_               => activity_seq_,
                                              condition_code_             => condition_code_,
                                              waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                              component_part_no_          => component_part_no_,
                                              line_item_no_               => line_item_no_,
                                              operation_no_               => operation_no_,
                                              location_no_                => location_no_,
                                              lot_batch_no_               => lot_batch_no_,
                                              serial_no_                  => serial_no_,
                                              handling_unit_id_           => handling_unit_id_,
                                              sscc_                       => sscc_,
                                              alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                              barcode_id_                 => barcode_id_,
                                              gtin_no_                    => gtin_no_);
                  ELSE
                     -- Data Items that are not part of the filter keys
                     Add_Unique_Data_Item_Detail___(capture_session_id_         => capture_session_id_,
                                                    session_rec_                => session_rec_,
                                                    owning_data_item_id_        => latest_data_item_id_,
                                                    owning_data_item_value_     => latest_data_item_value_,
                                                    data_item_detail_id_        => conf_item_detail_tab_(i).data_item_detail_id);
                  END IF;
               ELSE  -- FEEDBACK ITEMS AS DETAILS
                  IF (conf_item_detail_tab_(i).data_item_detail_id IN ('COMPONENT_PART_DESCRIPTION','CATCH_UNIT_MEAS', 'CATCH_UNIT_MEAS_DESCRIPTION', 'UNIT_MEAS',
                                                                       'UNIT_MEAS_DESCRIPTION', 'NET_WEIGHT', 'NET_VOLUME', 'PART_TYPE', 'PRIME_COMMODITY',
                                                                       'PRIME_COMMODITY_DESCRIPTION', 'SECOND_COMMODITY', 'SECOND_COMMODITY_DESCRIPTION',
                                                                       'ASSET_CLASS', 'ASSET_CLASS_DESCRIPTION', 'PART_STATUS', 'PART_STATUS_DESCRIPTION',
                                                                       'ABC_CLASS', 'ABC_CLASS_PERCENT', 'SAFETY_CODE', 'SAFETY_CODE_DESCRIPTION', 'ACCOUNTING_GROUP',
                                                                       'ACCOUNTING_GROUP_DESCRIPTION', 'PRODUCT_CODE', 'PRODUCT_CODE_DESCRIPTION', 'PRODUCT_FAMILY',
                                                                       'PRODUCT_FAMILY_DESCRIPTION', 'SERIAL_TRACKING_RECEIPT_ISSUE', 'SERIAL_TRACKING_INVENTORY',
                                                                       'SERIAL_TRACKING_DELIVERY', 'STOP_ARRIVAL_ISSUED_SERIAL', 'STOP_NEW_SERIAL_IN_RMA',
                                                                       'SERIAL_RULE', 'LOT_BATCH_TRACKING', 'LOT_QUANTITY_RULE', 'SUB_LOT_RULE',
                                                                       'COMPONENT_LOT_RULE', 'GTIN_IDENTIFICATION', 'GTIN_DEFAULT', 'INPUT_CONV_FACTOR')) THEN
                     Data_Capture_Invent_Util_API.Add_Details_For_Part_No(capture_session_id_   => capture_session_id_,
                                                                          owning_data_item_id_  => latest_data_item_id_,
                                                                          data_item_detail_id_  => conf_item_detail_tab_(i).data_item_detail_id,
                                                                          contract_             => contract_,
                                                                          part_no_              => component_part_no_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id IN ('QUANTITY_ONHAND', 'CATCH_QUANTITY_ONHAND', 'QUANTITY_AVAILABLE')) THEN
                     Data_Capture_Invent_Util_API.Add_Details_For_Inv_Stock_Rec(capture_session_id_  => capture_session_id_,
                                                                                owning_data_item_id_ => latest_data_item_id_,
                                                                                data_item_detail_id_ => conf_item_detail_tab_(i).data_item_detail_id,
                                                                                contract_            => contract_,
                                                                                part_no_             => component_part_no_,
                                                                                configuration_id_    => configuration_id_,
                                                                                location_no_         => location_no_,
                                                                                lot_batch_no_        => lot_batch_no_,
                                                                                serial_no_           => serial_no_,
                                                                                eng_chg_level_       => eng_chg_level_,
                                                                                waiv_dev_rej_no_     => waiv_dev_rej_no_,
                                                                                activity_seq_        => activity_seq_,
                                                                                handling_unit_id_    => handling_unit_id_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id IN ('WAREHOUSE_ID', 'BAY_ID', 'TIER_ID', 'ROW_ID','BIN_ID',
                                                                          'RECEIPTS_BLOCKED', 'MIX_OF_PART_NUMBER_BLOCKED', 'MIX_OF_CONDITION_CODES_BLOCKED',
                                                                          'MIX_OF_LOT_BATCH_NO_BLOCKED', 'LOCATION_GROUP', 'LOCATION_TYPE', 'LOCATION_NO_DESC')) THEN
                     Data_Capture_Invent_Util_API.Add_Details_For_Location_No(capture_session_id_  => capture_session_id_,
                                                                              owning_data_item_id_ => latest_data_item_id_,
                                                                              data_item_detail_id_ => conf_item_detail_tab_(i).data_item_detail_id,
                                                                              contract_            => contract_,
                                                                              location_no_         => location_no_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id IN ('START_DATE', 'FINISH_DATE', 'LOT_SIZE', 'PROPOSED_LOCATION',
                                                                          'SERIAL_BEGIN', 'SERIAL_END', 'DEMAND_CODE')) THEN
                     Data_Capture_Shopord_Util_API.Add_Details_For_Shop_Order(capture_session_id_   => capture_session_id_,
                                                                              owning_data_item_id_  => latest_data_item_id_,
                                                                              data_item_detail_id_  => conf_item_detail_tab_(i).data_item_detail_id,
                                                                              order_no_             => order_no_,
                                                                              release_no_           => release_no_,
                                                                              sequence_no_          => sequence_no_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id IN ('PROGRAM_ID', 'PROGRAM_DESCRIPTION', 'PROJECT_ID', 'PROJECT_NAME', 'SUB_PROJECT_ID',
                                                                          'SUB_PROJECT_DESCRIPTION', 'ACTIVITY_ID', 'ACTIVITY_DESCRIPTION')) THEN
                     Data_Capture_Invent_Util_API.Add_Details_For_Activity_Seq(capture_session_id_   => capture_session_id_,
                                                                               owning_data_item_id_  => latest_data_item_id_,
                                                                               data_item_detail_id_  => conf_item_detail_tab_(i).data_item_detail_id,
                                                                               activity_seq_         => activity_seq_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'PART_DESCRIPTION') THEN
                     Data_Capture_Invent_Util_API.Add_Part_Description(capture_session_id_  => capture_session_id_,
                                                                       owning_data_item_id_ => latest_data_item_id_,
                                                                       data_item_detail_id_ => conf_item_detail_tab_(i).data_item_detail_id,
                                                                       contract_            => contract_,
                                                                       part_no_             => part_no_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'CONDITION_CODE_DESCRIPTION') THEN
                     Data_Capture_Invent_Util_API.Add_Condition_Code_Desc(capture_session_id_   => capture_session_id_,
                                                                          owning_data_item_id_  => latest_data_item_id_,
                                                                          data_item_detail_id_  => conf_item_detail_tab_(i).data_item_detail_id,
                                                                          condition_code_       => condition_code_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'PART_QTY_ISSUED') THEN
                     Data_Capture_Shopord_Util_API.Add_Part_Qty_Issued(capture_session_id_  => capture_session_id_,
                                                                       owning_data_item_id_ => latest_data_item_id_,
                                                                       order_no_            => order_no_,
                                                                       release_no_          => release_no_,
                                                                       sequence_no_         => sequence_no_,
                                                                       line_item_no_        => line_item_no_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'QTY_REMAINING') THEN
                     Data_Capture_Shopord_Util_API.Add_Qty_Remaining(capture_session_id_  => capture_session_id_,
                                                                     owning_data_item_id_ => latest_data_item_id_,
                                                                     order_no_            => order_no_,
                                                                     release_no_          => release_no_,
                                                                     sequence_no_         => sequence_no_,
                                                                     line_item_no_        => line_item_no_,
                                                                     part_no_             => part_no_);
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'COMP_QTY_REQUESTED') THEN
                     Data_Capture_Shopord_Util_API.Add_Comp_Qty_Requested(capture_session_id_  => capture_session_id_,
                                                                          owning_data_item_id_ => latest_data_item_id_,
                                                                          order_no_            => order_no_,
                                                                          release_no_          => release_no_,
                                                                          sequence_no_         => sequence_no_,
                                                                          line_item_no_        => line_item_no_);
   
   
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'QTY_ASSIGNED') THEN
                     Data_Capture_Shopord_Util_API.Add_Qty_Assigned(capture_session_id_  => capture_session_id_,
                                                                    owning_data_item_id_ => latest_data_item_id_,
                                                                    order_no_            => order_no_,
                                                                    release_no_          => release_no_,
                                                                    sequence_no_         => sequence_no_,
                                                                    line_item_no_        => line_item_no_,
                                                                    contract_            => contract_,
                                                                    part_no_             => component_part_no_,
                                                                    location_no_         => location_no_,
                                                                    lot_batch_no_        => lot_batch_no_,
                                                                    serial_no_           => serial_no_,
                                                                    eng_chg_level_       => eng_chg_level_,
                                                                    waiv_dev_rej_no_     => waiv_dev_rej_no_,
                                                                    configuration_id_    => configuration_id_,
                                                                    activity_seq_        => activity_seq_,
                                                                    handling_unit_id_    => handling_unit_id_);
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id = 'EXPIRATION_DATE') THEN
                     Data_Capture_Invent_Util_API.Add_Details_For_Inv_Stock_Rec(capture_session_id_  => capture_session_id_,
                                                                                owning_data_item_id_ => latest_data_item_id_,
                                                                                data_item_detail_id_ => conf_item_detail_tab_(i).data_item_detail_id,
                                                                                contract_            => contract_,
                                                                                part_no_             => component_part_no_,
                                                                                configuration_id_    => configuration_id_,
                                                                                location_no_         => location_no_,
                                                                                lot_batch_no_        => lot_batch_no_,
                                                                                serial_no_           => serial_no_,
                                                                                eng_chg_level_       => eng_chg_level_,
                                                                                waiv_dev_rej_no_     => waiv_dev_rej_no_,
                                                                                activity_seq_        => activity_seq_,
                                                                                handling_unit_id_    => handling_unit_id_);
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id IN ('HANDLING_UNIT_TYPE_ID', 'HANDLING_UNIT_TYPE_DESC', 'HANDLING_UNIT_TYPE_CATEG_ID',
                                                                          'HANDLING_UNIT_TYPE_CATEG_DESC', 'HANDLING_UNIT_TYPE_ADD_VOLUME', 'HANDLING_UNIT_TYPE_MAX_VOL_CAP',
                                                                          'HANDLING_UNIT_TYPE_MAX_WGT_CAP', 'HANDLING_UNIT_TYPE_STACKABLE',
                                                         'TOP_PARENT_HANDLING_UNIT_TYPE_ID', 'TOP_PARENT_HANDLING_UNIT_TYPE_DESC')) THEN
                     -- Feedback items related to handling unit type
                     Data_Capture_Invent_Util_API.Add_Details_For_Hand_Unit_Type(capture_session_id_  => capture_session_id_,
                                                                                 owning_data_item_id_ => latest_data_item_id_,
                                                                                 data_item_detail_id_ => conf_item_detail_tab_(i).data_item_detail_id,
                                                                                 handling_unit_id_    => handling_unit_id_);
                  ELSIF (conf_item_detail_tab_(i).data_item_detail_id IN ('PARENT_HANDLING_UNIT_ID', 'HANDLING_UNIT_SHIPMENT_ID', 'HANDLING_UNIT_ACCESSORY_EXIST',
                                                                          'HANDLING_UNIT_COMPOSITION', 'HANDLING_UNIT_WIDTH', 'HANDLING_UNIT_HEIGHT',
                                                                          'HANDLING_UNIT_DEPTH', 'HANDLING_UNIT_UOM_LENGTH', 'HANDLING_UNIT_NET_WEIGHT',
                                                                          'HANDLING_UNIT_TARE_WEIGHT', 'HANDLING_UNIT_MANUAL_GROSS_WEIGHT', 'HANDLING_UNIT_OPERATIVE_GROSS_WEIGHT',
                                                                          'HANDLING_UNIT_UOM_WEIGHT', 'HANDLING_UNIT_MANUAL_VOLUME', 'HANDLING_UNIT_OPERATIVE_VOLUME',
                                                                          'HANDLING_UNIT_UOM_VOLUME', 'HANDLING_UNIT_GEN_SSCC', 'HANDLING_UNIT_PRINT_LBL', 'HANDLING_UNIT_NO_OF_LBLS',
                                                                          'HANDLING_UNIT_MIX_OF_PART_NO_BLOCKED', 'HANDLING_UNIT_MIX_OF_CONDITION_CODE_BLOCKED',
                                                                          'HANDLING_UNIT_MIX_OF_LOT_BATCH_NUMBERS_BLOCKED', 'TOP_PARENT_HANDLING_UNIT_ID',
                                                                          'TOP_PARENT_SSCC', 'TOP_PARENT_ALT_HANDLING_UNIT_LABEL_ID',
                                                                          'LEVEL_2_HANDLING_UNIT_ID', 'LEVEL_2_SSCC', 'LEVEL_2_ALT_HANDLING_UNIT_LABEL_ID')) THEN
                     -- Feedback items related to handling unit
                     Data_Capture_Invent_Util_API.Add_Details_For_Handling_Unit(capture_session_id_   => capture_session_id_,
                                                                                owning_data_item_id_  => latest_data_item_id_,
                                                                                data_item_detail_id_  => conf_item_detail_tab_(i).data_item_detail_id,
                                                                                handling_unit_id_     => handling_unit_id_);
   
                  END IF;
               END IF;
            END LOOP;
         END IF;
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Add_Details_For_Latest_Item');
   Core(capture_session_id_, latest_data_item_id_, latest_data_item_value_);
END Add_Details_For_Latest_Item;


PROCEDURE Execute_Process (
   process_message_    IN OUT NOCOPY VARCHAR2,
   capture_session_id_ IN NUMBER,
   contract_           IN VARCHAR2,
   attr_               IN VARCHAR2,
   blob_ref_attr_      IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      process_message_    IN OUT NOCOPY VARCHAR2,
      capture_session_id_ IN NUMBER,
      contract_           IN VARCHAR2,
      attr_               IN VARCHAR2,
      blob_ref_attr_      IN VARCHAR2 )
   IS
      ptr_                          NUMBER;
      name_                         VARCHAR2(50);
      value_                        VARCHAR2(4000);
      order_no_                     VARCHAR2(12);
      release_no_                   VARCHAR2(4);
      sequence_no_                  VARCHAR2(4);
      component_part_no_            VARCHAR2(25);
      location_no_                  VARCHAR2(35);
      lot_batch_no_                 VARCHAR2(20);
      serial_no_                    VARCHAR2(50);
      eng_chg_level_                VARCHAR2(6);
      waiv_dev_rej_no_              VARCHAR2(15);
      expiration_date_              DATE;
      activity_seq_                 NUMBER         := 0;
      catch_quantity_               NUMBER;
      condition_code_               VARCHAR2(10);
      line_item_no_                 NUMBER;
      qty_issued_                   NUMBER         := 1;
      part_tracking_session_id_     NUMBER;
      handling_unit_id_             NUMBER;
      part_no_                      VARCHAR2(25);
      chk_top_serial_               NUMBER;
      attr2_                        VARCHAR2(2000);
      attr_cf_                      VARCHAR2(2000);
      info_                         VARCHAR2(2000);
      objid_                        VARCHAR2(2000);
      objversion_                   VARCHAR2(2000);
      w_d_r_no_                     VARCHAR2(50);
      seq_no_                       VARCHAR2(50);
      comp_part_no_                 VARCHAR2(50);
      comp_serial_no_               VARCHAR2(50);
      comp_lot_batch_no_            VARCHAR2(50);
      comp_w_d_r_no_                VARCHAR2(50);
      barcode1_                     VARCHAR2(4000);
      barcode2_                     VARCHAR2(4000);
      chk_top_serial                NUMBER;
      comp_eng_chg_level_           VARCHAR2(6);
      quantity_                     NUMBER         := 1;
      comp_act_seq_                 NUMBER         := 0;
      part_ownership_               VARCHAR2(4000) := 'Company Owned';
      vim_struct_source_            VARCHAR2(50)   := 'MANUAL';
      
      CURSOR Get_W_D_R_No(contr_ VARCHAR2, pt_no_ VARCHAR2, ser_no_ VARCHAR2) IS
          SELECT v.waiv_dev_rej_no
          FROM INVENTORY_PART_IN_STOCK_UIV v
          WHERE v.contract = contr_
          	AND v.part_no = pt_no_
            AND v.serial_no = ser_no_
            AND v.qty_onhand = 1;
            
      CURSOR Get_Comp_Eng_Chg_Level(contr_ VARCHAR2, pt_no_ VARCHAR2) IS 
         SELECT v.eng_chg_level
         FROM PART_REVISION v 
         WHERE v.contract = contr_
           AND v.part_no = pt_no_;
           
      CURSOR Get_Line_Item_No(ord_no_ VARCHAR2, pt_no_ VARCHAR2) IS
          SELECT v.line_item_no
          FROM SHOP_MATERIAL_ALLOC_UIV v
          WHERE v.order_no = ord_no_
            AND v.so_part_no = pt_no_;
            
      CURSOR Check_Top_Serial_Exist(
                pt_no_             VARCHAR2, 
                ser_no_            VARCHAR2, 
                lot_bat_no_        VARCHAR2,
                waiv_dev_          VARCHAR2, 
                comp_part_no_      VARCHAR2, 
                comp_ser_no_       VARCHAR2, 
                comp_lot_bat_      VARCHAR2, 
                comp_w_d_r_        VARCHAR2,
                line_item_         VARCHAR2, 
                comp_act_sequence_ VARCHAR2, 
                comp_eng_chg_lvl_  VARCHAR2) IS
         SELECT DISTINCT  1
         FROM SERIAL_NO_RESERV_STRUCT v
         WHERE v.part_no = pt_no_
           AND v.serial_no = ser_no_
           AND v.lot_batch_no = lot_bat_no_
           AND v.waiv_dev_rej_no = waiv_dev_
           AND v.component_part_no = comp_part_no_
           AND v.component_serial_no = comp_ser_no_
           AND v.component_lot_batch_no = comp_lot_bat_
           AND v.component_waiv_dev_rej_no = comp_w_d_r_
           AND v.line_item_no = line_item_
           AND v.component_activity_seq = comp_act_sequence_
           AND v.component_eng_chg_level = comp_eng_chg_lvl_;
           
   BEGIN
      ptr_ := NULL;
      WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
         IF (name_ = 'ORDER_NO') THEN
            order_no_ := value_;
         ELSIF (name_ = 'RELEASE_NO') THEN
            release_no_ := value_;
         ELSIF (name_ = 'SEQUENCE_NO') THEN
            sequence_no_ := value_;
         ELSIF (name_ = 'COMPONENT_PART_NO') THEN
            component_part_no_ := value_;
         ELSIF (name_ = 'GS1_BARCODE1') THEN
            barcode1_ := value_;
         ELSIF (name_ = 'GS1_BARCODE2') THEN
            barcode2_ := value_;
         ELSIF (name_ = 'LOT_BATCH_NO') THEN
            lot_batch_no_ := value_;
         ELSIF (name_ = 'SERIAL_NO') THEN
            serial_no_ := value_;
         ELSIF (name_ = 'PART_NO') THEN
            part_no_ := value_;
         ELSIF (name_ = 'ENG_CHG_LEVEL') THEN
            eng_chg_level_ := value_;
         ELSIF (name_ = 'WAIV_DEV_REJ_NO') THEN
            waiv_dev_rej_no_ := value_;
         ELSIF (name_ = 'QUANTITY') THEN
            qty_issued_ := value_;
         ELSIF (name_ = 'EXPIRATION_DATE') THEN
            expiration_date_ := Client_SYS.Attr_Value_To_Date(value_);
         ELSIF (name_ = 'ACTIVITY_SEQ') THEN
            activity_seq_ := value_;
         ELSIF (name_ = 'CATCH_QUANTITY') THEN
            catch_quantity_ := value_;
         ELSIF (name_ = 'CONDITION_CODE') THEN
            condition_code_ := value_;
         ELSIF (name_ = 'HANDLING_UNIT_ID') THEN
            handling_unit_id_ := value_;
         ELSIF (name_ = 'COMPONENT_SERIAL_NO') THEN
            comp_serial_no_ := value_;
         ELSIF (name_ = 'COMPONENT_LOT_BATCH_NO') THEN
            comp_lot_batch_no_ := value_;
         END IF; 
      END LOOP;
      comp_serial_no_ := serial_no_;
      comp_lot_batch_no_ := lot_batch_no_;
      
      OPEN Get_W_D_R_No(contract_, component_part_no_, comp_serial_no_);
      FETCH Get_W_D_R_No INTO comp_w_d_r_no_;
      CLOSE Get_W_D_R_No;
         
      IF(comp_w_d_r_no_ IS NULL) THEN
         comp_w_d_r_no_ := '*';
      END IF;
                                                 
      OPEN Get_Line_Item_No(order_no_, part_no_);
      FETCH Get_Line_Item_No INTO line_item_no_;
      CLOSE Get_Line_Item_No;
         
      OPEN Get_Comp_Eng_Chg_Level(contract_, part_no_);
      FETCH Get_Comp_Eng_Chg_Level INTO comp_eng_chg_level_;
      CLOSE Get_Comp_Eng_Chg_Level;
      
      OPEN Check_Top_Serial_Exist(
              part_no_,
              serial_no_, 
              lot_batch_no_, 
              waiv_dev_rej_no_, 
              component_part_no_, 
              comp_serial_no_, 
              comp_lot_batch_no_, 
              comp_w_d_r_no_, 
              line_item_no_, 
              comp_act_seq_, 
              comp_eng_chg_level_);
              
      FETCH Check_Top_Serial_Exist INTO chk_top_serial_; 
               
         Client_SYS.Clear_Attr(attr2_);
         Client_SYS.Add_To_Attr('PART_NO', part_no_, attr2_);
         Client_SYS.Add_To_Attr('SERIAL_NO', serial_no_, attr2_);
         Client_SYS.Add_To_Attr('LOT_BATCH_NO', lot_batch_no_, attr2_);
         Client_SYS.Add_To_Attr('WAIV_DEV_REJ_NO', waiv_dev_rej_no_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_PART_NO', component_part_no_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_SERIAL_NO', comp_serial_no_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_LOT_BATCH_NO',comp_lot_batch_no_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_WAIV_DEV_REJ_NO', comp_w_d_r_no_, attr2_);
         Client_SYS.Add_To_Attr('LINE_ITEM_NO', line_item_no_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_ACTIVITY_SEQ', comp_act_seq_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_ENG_CHG_LEVEL', comp_eng_chg_level_, attr2_);
         Client_SYS.Add_To_Attr('QUANTITY', quantity_, attr2_);
         Client_SYS.Add_To_Attr('COMPONENT_QUANTITY', 1, attr2_);
         Client_SYS.Add_To_Attr('ORDER_NO', order_no_, attr2_);
         Client_SYS.Add_To_Attr('RELEASE_NO', release_no_, attr2_);
         Client_SYS.Add_To_Attr('SEQUENCE_NO', sequence_no_, attr2_);
         Client_SYS.Add_To_Attr('PART_OWNERSHIP', part_ownership_, attr2_);
         Client_SYS.Add_To_Attr('VIM_STRUCTURE_SOURCE', vim_struct_source_, attr2_);
         
      IF Check_Top_Serial_Exist%FOUND THEN
         CLOSE Check_Top_Serial_Exist;
         -- Error message if a record for the scanned data already exist.
         Error_SYS.Record_General(lu_name_, 'TRCKDSTRUCTEXIST: Tracked Structure record already exists!');
      END IF;
      
      Serial_No_Reserv_Struct_API.New__ (info_, objid_, objversion_, attr2_, 'DO');
      COMMIT;
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Execute_Process');
   Core(process_message_, capture_session_id_, contract_, attr_, blob_ref_attr_);
END Execute_Process;


--@IgnoreMissingSysinit
FUNCTION Is_Process_Available (
   capture_process_id_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   
   FUNCTION Core (
      capture_process_id_  IN VARCHAR2 ) RETURN VARCHAR2
   IS
      process_available_ VARCHAR2(5);
   BEGIN
      IF (Security_SYS.Is_Method_Available('Shop_Ord_API.Receive_Part__')) THEN
         process_available_ := Fnd_Boolean_API.DB_TRUE;
      ELSE
         process_available_ := Fnd_Boolean_API.DB_FALSE;
      END IF;
      RETURN process_available_;
   END Core;

BEGIN
   RETURN Core(capture_process_id_);
END Is_Process_Available;


FUNCTION Fixed_Value_Is_Applicable (
   capture_session_id_ IN NUMBER,
   data_item_id_       IN VARCHAR2) RETURN BOOLEAN
IS
   
   FUNCTION Core (
      capture_session_id_ IN NUMBER,
      data_item_id_       IN VARCHAR2) RETURN BOOLEAN
   IS
      session_rec_                 Data_Capture_Common_Util_API.Session_Rec;
      process_package_             VARCHAR2(30);
      contract_                    VARCHAR2(5);
      part_no_                     VARCHAR2(25);
      component_part_no_           VARCHAR2(25);
      order_no_                    VARCHAR2(12);
      release_no_                  VARCHAR2(4);
      sequence_no_                 VARCHAR2(4);
      eng_chg_level_               VARCHAR2(6);
      lot_batch_no_                VARCHAR2(20);
      activity_seq_                NUMBER;
      condition_code_              VARCHAR2(10);
      location_no_                 VARCHAR2(35);
      line_item_no_                NUMBER;
      operation_no_                NUMBER;
      serial_no_                   VARCHAR2(50);
      waiv_dev_rej_no_             VARCHAR2(15);
      barcode_id_                  NUMBER;
      handling_unit_id_            NUMBER;
      sscc_                        VARCHAR2(18);
      alt_handling_unit_label_id_  VARCHAR2(25);
      gtin_no_                     VARCHAR2(14);
      
   BEGIN
      -- NOTE: Calling Data_Capture_Session_API.Get_Predicted_Data_Item_Value and Get_Filter_Keys___ with use_applicable = FALSE to avoid
      --       "maximum number of recursive SQL levels" errors since Data_Capture_Session_API.Get_Predicted_Data_Item_Value could call this method for some data items.
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         session_rec_       := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
         process_package_   := Data_Capture_Process_API.Get_Process_Package(session_rec_.capture_process_id);
         component_part_no_ := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, NULL, 'COMPONENT_PART_NO', session_rec_ , process_package_, use_applicable_ => FALSE, process_part_no_id_ => 'COMPONENT_PART_NO');
         -- if predicted component_part_no_ is null then try fetch it with unique handling
         IF (component_part_no_ IS NULL) THEN
            Get_Filter_Keys___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                               component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_,
                               handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_, use_applicable_ => FALSE);
            component_part_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                                component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'COMPONENT_PART_NO');
         END IF;
         IF (serial_no_ IS NULL) AND (data_item_id_ = 'QUANTITY') THEN
            serial_no_ := Data_Capture_Session_API.Get_Latest_A_If_Before_B(capture_session_id_, 'SERIAL_NO', data_item_id_);
         END IF;
      $END
   
      RETURN Data_Capture_Shopord_Util_API.Fixed_Value_Is_Applicable(capture_session_id_, data_item_id_, component_part_no_, serial_no_);
   END Core;

BEGIN
   General_SYS.Init_Method(C_EA_Data_Capt_Man_Iss_Pt_API.lu_name_, 'C_EA_Data_Capt_Man_Iss_Pt_API', 'Fixed_Value_Is_Applicable');
   RETURN Core(capture_session_id_, data_item_id_);
END Fixed_Value_Is_Applicable;

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
-----------------------------------------------------------------------------

FUNCTION Get_Unique_Data_Item_Value___ (
   contract_                   IN VARCHAR2,
   order_no_                   IN VARCHAR2,
   release_no_                 IN VARCHAR2,
   sequence_no_                IN VARCHAR2,
   part_no_                    IN VARCHAR2,
   eng_chg_level_              IN VARCHAR2,
   activity_seq_               IN NUMBER,
   condition_code_             IN VARCHAR2,
   waiv_dev_rej_no_            IN VARCHAR2,
   component_part_no_          IN VARCHAR2,
   line_item_no_               IN NUMBER,
   operation_no_               IN NUMBER,
   location_no_                IN VARCHAR2,
   lot_batch_no_               IN VARCHAR2,
   serial_no_                  IN VARCHAR2,
   handling_unit_id_           IN NUMBER,
   alt_handling_unit_label_id_ IN VARCHAR2,
   barcode_id_                 IN NUMBER,
   wanted_data_item_id_        IN VARCHAR2 ) RETURN VARCHAR2
IS
   
   FUNCTION Core (
      contract_                   IN VARCHAR2,
      order_no_                   IN VARCHAR2,
      release_no_                 IN VARCHAR2,
      sequence_no_                IN VARCHAR2,
      part_no_                    IN VARCHAR2,
      eng_chg_level_              IN VARCHAR2,
      activity_seq_               IN NUMBER,
      condition_code_             IN VARCHAR2,
      waiv_dev_rej_no_            IN VARCHAR2,
      component_part_no_          IN VARCHAR2,
      line_item_no_               IN NUMBER,
      operation_no_               IN NUMBER,
      location_no_                IN VARCHAR2,
      lot_batch_no_               IN VARCHAR2,
      serial_no_                  IN VARCHAR2,
      handling_unit_id_           IN NUMBER,
      alt_handling_unit_label_id_ IN VARCHAR2,
      barcode_id_                 IN NUMBER,
      wanted_data_item_id_        IN VARCHAR2 ) RETURN VARCHAR2
   IS
      unique_value_          VARCHAR2(200);
      shopord_activity_seq_  NUMBER;
      local_data_item_id_    VARCHAR2(50);
      configuration_id_      VARCHAR2(50);
      sql_where_expression_  VARCHAR2(2000);
      dummy_                 BOOLEAN;
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         -- NOTE: For future refactoring/bug fixing we might have to change shopord_activity_seq_ handling here. Since now we can't see the difference between if the value actually is NULL
         -- or because ACTIVITY_SEQ comes after current data item in the configuration. It might be better to set it to '%' or -1 and change
         -- Shop_Ord_Util_API.Get_Column_Value_If_Unique/Shop_Material_Alloc_API.Get_Column_Value_If_Unique to handle %/-1 for shopord_activity_seq_.
         IF (activity_seq_ = 0) THEN
            shopord_activity_seq_ := NULL;  -- shop_ord have NULL instead of 0 for non project parts
         ELSE
            shopord_activity_seq_ := activity_seq_;
         END IF;
   
         configuration_id_ := NVL(Shop_Material_Alloc_API.Get_Configuration_Id(order_no_, release_no_, sequence_no_, line_item_no_), '*');
   
         IF (wanted_data_item_id_ = 'BARCODE_ID' OR (barcode_id_ IS NOT NULL AND
             wanted_data_item_id_ IN ('COMPONENT_PART_NO', 'LOT_BATCH_NO', 'SERIAL_NO', 'ENG_CHG_LEVEL', 'WAIV_DEV_REJ_NO', 'ACTIVITY_SEQ'))) THEN
   
            IF (wanted_data_item_id_ = 'COMPONENT_PART_NO') THEN
               local_data_item_id_ := 'PART_NO';
            ELSE
               local_data_item_id_ := wanted_data_item_id_;
            END IF;
            unique_value_ := Inventory_Part_Barcode_API.Get_Column_Value_If_Unique(contract_         => contract_,
                                                                                   barcode_id_       => barcode_id_,
                                                                                   part_no_          => component_part_no_,
                                                                                   configuration_id_ => configuration_id_,
                                                                                   lot_batch_no_     => lot_batch_no_,
                                                                                   serial_no_        => serial_no_,
                                                                                   eng_chg_level_    => eng_chg_level_,
                                                                                   waiv_dev_rej_no_  => waiv_dev_rej_no_,
                                                                                   activity_seq_     => activity_seq_,
                                                                                   column_name_      => local_data_item_id_ );
            IF (wanted_data_item_id_ = 'SERIAL_NO' AND
                Part_Catalog_API.Get_Rcpt_Issue_Serial_Track_Db(component_part_no_) = Fnd_Boolean_API.DB_TRUE AND
                Part_Catalog_API.Get_Serial_Tracking_Code_Db(component_part_no_) = Part_Serial_Tracking_API.DB_NOT_SERIAL_TRACKING AND
                Inventory_Part_Barcode_API.Get_Serial_No(contract_, barcode_id_) = '*') THEN
                  unique_value_ := NULL;
            END IF;
         ELSIF (wanted_data_item_id_ IN ('ORDER_NO','RELEASE_NO','SEQUENCE_NO', 'PART_NO')) THEN
            unique_value_ := Shop_Ord_Util_API.Get_Column_Value_If_Unique(contract_              => contract_,
                                                                          order_no_              => order_no_,
                                                                          release_no_            => release_no_,
                                                                          sequence_no_           => sequence_no_,
                                                                          part_no_               => part_no_,
                                                                          eng_chg_level_         => eng_chg_level_,
                                                                          activity_seq_          => shopord_activity_seq_,
                                                                          condition_code_        => condition_code_,
                                                                          lot_batch_no_          => NULL,
                                                                          component_part_no_     => component_part_no_,
                                                                          column_name_           => wanted_data_item_id_);
   
         ELSIF (wanted_data_item_id_ IN ('LOT_BATCH_NO','SERIAL_NO','WAIV_DEV_REJ_NO','ACTIVITY_SEQ', 'ENG_CHG_LEVEL', 'LOCATION_NO',
                                         'HANDLING_UNIT_ID', 'SSCC', 'ALT_HANDLING_UNIT_LABEL_ID')) THEN
   
            sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
            unique_value_ := Inventory_Part_In_Stock_API.Get_Column_Value_If_Unique(no_unique_value_found_      => dummy_,
                                                                                    contract_                   => contract_,
                                                                                    part_no_                    => component_part_no_,
                                                                                    location_no_                => location_no_,
                                                                                    eng_chg_level_              => eng_chg_level_,
                                                                                    activity_seq_               => activity_seq_,
                                                                                    lot_batch_no_               => lot_batch_no_,
                                                                                    serial_no_                  => serial_no_,
                                                                                    configuration_id_           => configuration_id_,
                                                                                    waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                                    handling_unit_id_           => handling_unit_id_,
                                                                                    alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                                    column_name_                => wanted_data_item_id_,
                                                                                    sql_where_expression_       => sql_where_expression_);
   
         ELSIF (wanted_data_item_id_ IN ('COMPONENT_PART_NO','LINE_ITEM_NO', 'CONDITION_CODE', 'OPERATION_NO')) THEN
            IF (wanted_data_item_id_ = 'COMPONENT_PART_NO') THEN
               local_data_item_id_ := 'PART_NO';
            ELSE
               local_data_item_id_ := wanted_data_item_id_;
            END IF;
            unique_value_ := Shop_Material_Alloc_API.Get_Column_Value_If_Unique(contract_              => contract_,
                                                                                order_no_              => order_no_,
                                                                                release_no_            => release_no_,
                                                                                sequence_no_           => sequence_no_,
                                                                                part_no_               => component_part_no_,
                                                                                line_item_no_          => line_item_no_,
                                                                                activity_seq_          => shopord_activity_seq_,
                                                                                condition_code_        => condition_code_,
                                                                                operation_no_          => operation_no_,
                                                                                column_name_           => local_data_item_id_);
   
         END IF;
         IF (unique_value_ = 'NULL') THEN
            unique_value_ := NULL;
         END IF;
      $END
      RETURN unique_value_;
   END Core;

BEGIN
   RETURN Core(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_, component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, wanted_data_item_id_);
END Get_Unique_Data_Item_Value___;


PROCEDURE Get_Filter_Keys___ (
   contract_                   OUT VARCHAR2,
   order_no_                   OUT VARCHAR2,
   release_no_                 OUT VARCHAR2,
   sequence_no_                OUT VARCHAR2,
   part_no_                    OUT VARCHAR2,
   eng_chg_level_              OUT VARCHAR2,
   activity_seq_               OUT NUMBER,
   condition_code_             OUT VARCHAR2,
   waiv_dev_rej_no_            OUT VARCHAR2,
   component_part_no_          OUT VARCHAR2,
   line_item_no_               OUT NUMBER,
   operation_no_               OUT NUMBER,
   location_no_                OUT VARCHAR2,
   lot_batch_no_               OUT VARCHAR2,
   serial_no_                  OUT VARCHAR2,
   barcode_id_                 OUT NUMBER,
   gtin_no_                    OUT VARCHAR2,
   handling_unit_id_           OUT NUMBER,
   sscc_                       OUT VARCHAR2,  
   alt_handling_unit_label_id_ OUT VARCHAR2,
   capture_session_id_         IN  NUMBER,
   data_item_id_               IN  VARCHAR2,
   data_item_value_            IN  VARCHAR2 DEFAULT NULL,
   use_unique_values_          IN  BOOLEAN  DEFAULT FALSE,
   use_applicable_             IN  BOOLEAN  DEFAULT TRUE )
IS
   
   PROCEDURE Core (
      contract_                   OUT VARCHAR2,
      order_no_                   OUT VARCHAR2,
      release_no_                 OUT VARCHAR2,
      sequence_no_                OUT VARCHAR2,
      part_no_                    OUT VARCHAR2,
      eng_chg_level_              OUT VARCHAR2,
      activity_seq_               OUT NUMBER,
      condition_code_             OUT VARCHAR2,
      waiv_dev_rej_no_            OUT VARCHAR2,
      component_part_no_          OUT VARCHAR2,
      line_item_no_               OUT NUMBER,
      operation_no_               OUT NUMBER,
      location_no_                OUT VARCHAR2,
      lot_batch_no_               OUT VARCHAR2,
      serial_no_                  OUT VARCHAR2,
      barcode_id_                 OUT NUMBER,
      gtin_no_                    OUT VARCHAR2,
      handling_unit_id_           OUT NUMBER,
      sscc_                       OUT VARCHAR2,  
   alt_handling_unit_label_id_ OUT VARCHAR2,
      capture_session_id_         IN  NUMBER,
      data_item_id_               IN  VARCHAR2,
      data_item_value_            IN  VARCHAR2 DEFAULT NULL,
      use_unique_values_          IN  BOOLEAN  DEFAULT FALSE,
      use_applicable_             IN  BOOLEAN  DEFAULT TRUE )
   IS
      session_rec_         Data_Capture_Common_Util_API.Session_Rec;
      process_package_     VARCHAR2(30);
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         session_rec_     := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
         contract_        := session_rec_.session_contract;
         process_package_ := Data_Capture_Process_API.Get_Process_Package(session_rec_.capture_process_id);
   
         -- First try and fetch "predicted" filter keys
         order_no_          := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'ORDER_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         release_no_        := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'RELEASE_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         sequence_no_       := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'SEQUENCE_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         part_no_           := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'PART_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         eng_chg_level_     := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'ENG_CHG_LEVEL', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         activity_seq_      := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'ACTIVITY_SEQ', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         condition_code_    := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'CONDITION_CODE', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         waiv_dev_rej_no_   := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'WAIV_DEV_REJ_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         component_part_no_ := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'COMPONENT_PART_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         line_item_no_      := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'LINE_ITEM_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         operation_no_      := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'OPERATION_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         location_no_       := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'LOCATION_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         lot_batch_no_      := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'LOT_BATCH_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         serial_no_         := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'SERIAL_NO', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         handling_unit_id_  := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'HANDLING_UNIT_ID', session_rec_ , process_package_, use_applicable_);
         sscc_              := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'SSCC', session_rec_ , process_package_, use_applicable_);
         alt_handling_unit_label_id_ := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'ALT_HANDLING_UNIT_LABEL_ID', session_rec_ , process_package_, use_applicable_);
   
         -- Also fetch predicted barcode_id since this process can use barcodes
         barcode_id_        := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'BARCODE_ID', session_rec_ , process_package_, use_applicable_, 'COMPONENT_PART_NO');
         gtin_no_           := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_, data_item_id_, data_item_value_, 'GTIN', session_rec_ , process_package_, use_applicable_);      
   
         -- if condition_code_ comes after current data item, we exchange the parameter with % since this column in the table can be NULL
         -- so we need to specifiy that we have to compare to all condition codes in the table
         IF (condition_code_ IS NULL AND
             NOT Data_Capt_Conf_Data_Item_API.Is_A_Before_B(session_rec_.capture_process_id, session_rec_.capture_config_id, 'CONDITION_CODE', data_item_id_)) THEN
            condition_code_ := '%';
         END IF;
   
         -- Add support for alternative handling unit keys
         IF (handling_unit_id_ IS NULL AND sscc_ IS NOT NULL) THEN
            handling_unit_id_ := Handling_Unit_API.Get_Handling_Unit_From_Sscc(sscc_);
         ELSIF (handling_unit_id_ IS NULL AND alt_handling_unit_label_id_ IS NOT NULL) THEN
            handling_unit_id_ := Handling_Unit_API.Get_Handling_Unit_From_Alt_Id(alt_handling_unit_label_id_);
         END IF;
         IF (sscc_ IS NULL AND handling_unit_id_ IS NOT NULL) THEN
            sscc_ := Handling_Unit_API.Get_Sscc(handling_unit_id_);
         END IF;
         IF (alt_handling_unit_label_id_ IS NULL AND handling_unit_id_ IS NOT NULL) THEN
            alt_handling_unit_label_id_ := Handling_Unit_API.Get_Alt_Handling_Unit_Label_Id(handling_unit_id_);
         END IF;
   
         -- if alt_handling_unit_label_id_ comes after current data item, we exchange the parameter with % since this column in the view can be NULL
         -- so we need to specifiy that we have to compare to all alternative handling unit label ids in the table
         IF (alt_handling_unit_label_id_ IS NULL AND
             NOT Data_Capt_Conf_Data_Item_API.Is_A_Before_B(session_rec_.capture_process_id, session_rec_.capture_config_id, 'ALT_HANDLING_UNIT_LABEL_ID', data_item_id_)) THEN
            alt_handling_unit_label_id_ := '%';
         END IF;
   
         -- if operation_no_ comes after current data item, we exchange the parameter with -1 since this column in the view can be NULL
         -- so we need to specifiy that we have to compare to all operations in the table, both null and those with value.
         IF (operation_no_ IS NULL AND
             NOT Data_Capt_Conf_Data_Item_API.Is_A_Before_B(session_rec_.capture_process_id, session_rec_.capture_config_id, 'OPERATION_NO', data_item_id_)) THEN
            operation_no_ := -1;
         END IF;
         
         IF (gtin_no_ IS NULL AND Data_Capture_Invent_Util_API.Gtin_Enabled(session_rec_.capture_process_id, session_rec_.capture_config_id)) THEN
            gtin_no_ := Part_Gtin_API.Get_Default_Gtin_No(component_part_no_);
         END IF;
         
         IF ((component_part_no_ IS NULL) AND (gtin_no_ IS NOT NULL)) THEN
            component_part_no_ := Part_Gtin_API.Get_Part_Via_Identified_Gtin(gtin_no_); 
         END IF;
   
         IF use_unique_values_ THEN
            -- If some filter keys still are NULL then try and fetch those with unique handling instead
            IF (order_no_ IS NULL) THEN
               order_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                          component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'ORDER_NO');
            END IF;
            IF (release_no_ IS NULL) THEN
               release_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                            component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'RELEASE_NO');
            END IF;
            IF (sequence_no_ IS NULL) THEN
               sequence_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                             component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'SEQUENCE_NO');
            END IF;
            IF (part_no_ IS NULL) THEN
               part_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                         component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'PART_NO');
            END IF;
            IF (eng_chg_level_ IS NULL) THEN
               eng_chg_level_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                               component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'ENG_CHG_LEVEL');
            END IF;
            IF (activity_seq_ IS NULL) THEN
               activity_seq_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                              component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'ACTIVITY_SEQ');
            END IF;
            IF (condition_code_ IS NULL) THEN
               condition_code_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                                component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'CONDITION_CODE');
            END IF;
            IF (waiv_dev_rej_no_ IS NULL) THEN
               waiv_dev_rej_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                                 component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'WAIV_DEV_REJ_NO');
            END IF;
            IF (component_part_no_ IS NULL) THEN
               component_part_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                                   component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'COMPONENT_PART_NO');
            END IF;
            IF (line_item_no_ IS NULL) THEN
               line_item_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                              component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'LINE_ITEM_NO');
            END IF;
            IF (operation_no_ IS NULL) THEN
               operation_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                              component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'OPERATION_NO');
            END IF;
            IF (location_no_ IS NULL) THEN
               location_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                             component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'LOCATION_NO');
            END IF;
            IF (lot_batch_no_ IS NULL) THEN
               lot_batch_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                              component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'LOT_BATCH_NO');
            END IF;
            IF (serial_no_ IS NULL) THEN
               serial_no_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                           component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'SERIAL_NO');
            END IF;
            IF (handling_unit_id_ IS NULL) THEN
               handling_unit_id_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                           component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'HANDLING_UNIT_ID');
            END IF;
            -- Modified IF condition by checking whether the Barcode Id is mandatory before fetching because otherwise it would not be useful.
            IF (barcode_id_ IS NULL AND Data_Capture_Shopord_Util_API.Inventory_Barcode_Enabled(session_rec_.capture_process_id, session_rec_.capture_config_id)) THEN
               barcode_id_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
                                                            component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, 'BARCODE_ID');
            END IF;
            --  SSCC not included in the unique fetch
         END IF;
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   Core(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_, component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, barcode_id_, gtin_no_, handling_unit_id_, sscc_, alt_handling_unit_label_id_, capture_session_id_, data_item_id_, data_item_value_, use_unique_values_, use_applicable_);
END Get_Filter_Keys___;


PROCEDURE Add_Filter_Key_Detail___ (
   capture_session_id_         IN NUMBER,
   owning_data_item_id_        IN VARCHAR2,
   data_item_detail_id_        IN VARCHAR2,
   order_no_                   IN VARCHAR2,
   release_no_                 IN VARCHAR2,
   sequence_no_                IN VARCHAR2,
   part_no_                    IN VARCHAR2,
   eng_chg_level_              IN VARCHAR2,
   activity_seq_               IN NUMBER,
   condition_code_             IN VARCHAR2,
   waiv_dev_rej_no_            IN VARCHAR2,
   component_part_no_          IN VARCHAR2,
   line_item_no_               IN NUMBER,
   operation_no_               IN NUMBER,
   location_no_                IN VARCHAR2,
   lot_batch_no_               IN VARCHAR2,
   serial_no_                  IN VARCHAR2,
   handling_unit_id_           IN NUMBER,
   sscc_                       IN VARCHAR2,
   alt_handling_unit_label_id_ IN VARCHAR2,
   barcode_id_                 IN NUMBER,
   gtin_no_                    IN VARCHAR2)
IS
   
   PROCEDURE Core (
      capture_session_id_         IN NUMBER,
      owning_data_item_id_        IN VARCHAR2,
      data_item_detail_id_        IN VARCHAR2,
      order_no_                   IN VARCHAR2,
      release_no_                 IN VARCHAR2,
      sequence_no_                IN VARCHAR2,
      part_no_                    IN VARCHAR2,
      eng_chg_level_              IN VARCHAR2,
      activity_seq_               IN NUMBER,
      condition_code_             IN VARCHAR2,
      waiv_dev_rej_no_            IN VARCHAR2,
      component_part_no_          IN VARCHAR2,
      line_item_no_               IN NUMBER,
      operation_no_               IN NUMBER,
      location_no_                IN VARCHAR2,
      lot_batch_no_               IN VARCHAR2,
      serial_no_                  IN VARCHAR2,
      handling_unit_id_           IN NUMBER,
      sscc_                       IN VARCHAR2,
      alt_handling_unit_label_id_ IN VARCHAR2,
      barcode_id_                 IN NUMBER,
      gtin_no_                    IN VARCHAR2) 
   IS
      detail_value_             VARCHAR2(200);
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         CASE (data_item_detail_id_)
            WHEN ('ORDER_NO') THEN
               detail_value_ := order_no_;
            WHEN ('RELEASE_NO') THEN
               detail_value_ := release_no_;
            WHEN ('SEQUENCE_NO') THEN
               detail_value_ := sequence_no_;
            WHEN ('PART_NO') THEN
               detail_value_ := part_no_;
            WHEN ('ENG_CHG_LEVEL') THEN
               detail_value_ := eng_chg_level_;
            WHEN ('ACTIVITY_SEQ') THEN
               detail_value_ := activity_seq_;
            WHEN ('CONDITION_CODE') THEN
               detail_value_ := condition_code_;
            WHEN ('WAIV_DEV_REJ_NO') THEN
               detail_value_ := waiv_dev_rej_no_;
            WHEN ('COMPONENT_PART_NO') THEN
               detail_value_ := component_part_no_;
            WHEN ('LINE_ITEM_NO') THEN
               detail_value_ := line_item_no_;
            WHEN ('OPERATION_NO') THEN
               detail_value_ := operation_no_;
            WHEN ('LOCATION_NO') THEN
               detail_value_ := location_no_;
            WHEN ('LOT_BATCH_NO') THEN
               detail_value_ := lot_batch_no_;
            WHEN ('SERIAL_NO') THEN
               detail_value_ := serial_no_;
            WHEN ('HANDLING_UNIT_ID') THEN
               detail_value_ := handling_unit_id_;
            WHEN ('SSCC') THEN
               detail_value_ := sscc_;
            WHEN ('ALT_HANDLING_UNIT_LABEL_ID') THEN
               detail_value_ := alt_handling_unit_label_id_;
            WHEN ('BARCODE_ID') THEN
               detail_value_ := barcode_id_;
            WHEN ('GTIN') THEN
               detail_value_ := gtin_no_;  
            ELSE
               NULL;
         END CASE;
   
         Data_Capture_Session_Line_API.New(capture_session_id_    => capture_session_id_,
                                           data_item_id_          => owning_data_item_id_,
                                           data_item_detail_id_   => data_item_detail_id_,
                                           data_item_value_       => detail_value_);
   
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   Core(capture_session_id_, owning_data_item_id_, data_item_detail_id_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_, component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, sscc_, alt_handling_unit_label_id_, barcode_id_, gtin_no_);
END Add_Filter_Key_Detail___;


PROCEDURE Add_Unique_Data_Item_Detail___ (
   capture_session_id_         IN NUMBER,
   session_rec_                IN Data_Capture_Common_Util_API.Session_Rec,
   owning_data_item_id_        IN VARCHAR2,
   owning_data_item_value_     IN VARCHAR2,
   data_item_detail_id_        IN VARCHAR2 )
IS
   
   PROCEDURE Core (
      capture_session_id_         IN NUMBER,
      session_rec_                IN Data_Capture_Common_Util_API.Session_Rec,
      owning_data_item_id_        IN VARCHAR2,
      owning_data_item_value_     IN VARCHAR2,
      data_item_detail_id_        IN VARCHAR2 )
   IS
      detail_value_          VARCHAR2(4000);
      process_package_       VARCHAR2(30);
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         process_package_ := Data_Capture_Process_API.Get_Process_Package(session_rec_.capture_process_id);
         -- All non filter key data items, try and fetch their predicted value
         detail_value_ := Data_Capture_Session_API.Get_Predicted_Data_Item_Value(capture_session_id_      => capture_session_id_,
                                                                                 current_data_item_id_    => owning_data_item_id_,
                                                                                 current_data_item_value_ => owning_data_item_value_,
                                                                                 wanted_data_item_id_     => data_item_detail_id_,
                                                                                 session_rec_             => session_rec_,
                                                                                 process_package_         => process_package_,
                                                                                 process_part_no_id_      => 'COMPONENT_PART_NO');
   
         -- Non filter key data items or feedback items that could be fetched by unique handling
         -- Add any such items here, at the moment none exist so code is commented
   --(-)      /*IF (detail_value_ IS NULL AND data_item_detail_id_ IN ()) THEN
   --(-)         detail_value_ := Get_Unique_Data_Item_Value___(contract_, order_no_, release_no_, sequence_no_, part_no_, eng_chg_level_, activity_seq_, condition_code_, waiv_dev_rej_no_,
   --(-)                                                        component_part_no_, line_item_no_, operation_no_, location_no_, lot_batch_no_, serial_no_, handling_unit_id_, alt_handling_unit_label_id_, barcode_id_, data_item_detail_id_);
   --(-)      END IF;*/
   
         Data_Capture_Session_Line_API.New(capture_session_id_    => capture_session_id_,
                                           data_item_id_          => owning_data_item_id_,
                                           data_item_detail_id_   => data_item_detail_id_,
                                           data_item_value_       => detail_value_);
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   Core(capture_session_id_, session_rec_, owning_data_item_id_, owning_data_item_value_, data_item_detail_id_);
END Add_Unique_Data_Item_Detail___;


PROCEDURE Validate_Data_Item___ (
   contract_                   IN VARCHAR2,
   order_no_                   IN VARCHAR2,
   release_no_                 IN VARCHAR2,
   sequence_no_                IN VARCHAR2,
   line_item_no_               IN NUMBER,
   component_part_no_          IN VARCHAR2,
   location_no_                IN VARCHAR2,
   lot_batch_no_               IN VARCHAR2,
   serial_no_                  IN VARCHAR2,
   eng_chg_level_              IN VARCHAR2,
   waiv_dev_rej_no_            IN VARCHAR2,
   configuration_id_           IN VARCHAR2,
   activity_seq_               IN NUMBER,
   handling_unit_id_           IN NUMBER,
   alt_handling_unit_label_id_ IN VARCHAR2,
   data_item_id_               IN VARCHAR2,
   data_item_value_            IN VARCHAR2,
   capture_session_id_         IN NUMBER)
IS
   
   PROCEDURE Core (
      contract_                   IN VARCHAR2,
      order_no_                   IN VARCHAR2,
      release_no_                 IN VARCHAR2,
      sequence_no_                IN VARCHAR2,
      line_item_no_               IN NUMBER,
      component_part_no_          IN VARCHAR2,
      location_no_                IN VARCHAR2,
      lot_batch_no_               IN VARCHAR2,
      serial_no_                  IN VARCHAR2,
      eng_chg_level_              IN VARCHAR2,
      waiv_dev_rej_no_            IN VARCHAR2,
      configuration_id_           IN VARCHAR2,
      activity_seq_               IN NUMBER,
      handling_unit_id_           IN NUMBER,
      alt_handling_unit_label_id_ IN VARCHAR2,
      data_item_id_               IN VARCHAR2,
      data_item_value_            IN VARCHAR2,
      capture_session_id_         IN NUMBER)
   IS
      part_catalog_rec_           Part_Catalog_API.Public_Rec;
      data_item_description_      VARCHAR2(200);
      session_rec_                Data_Capture_Common_Util_API.Session_Rec;
      filter_serial_no_           VARCHAR2(50);
      qty_reserved_               NUMBER;
      sql_where_expression_       VARCHAR2(2000);
      column_value_exist_check_   BOOLEAN := TRUE;
      column_value_nullable_      BOOLEAN := FALSE;
   
   BEGIN
      $IF Component_Wadaco_SYS.INSTALLED $THEN
         part_catalog_rec_      := Part_Catalog_API.Get(component_part_no_);
         session_rec_           := Data_Capture_Session_API.Get_Session_Rec(capture_session_id_);
         data_item_description_ := Data_Capt_Proc_Data_Item_API.Get_Description(session_rec_.capture_process_id, data_item_id_);
   
         IF (data_item_id_ IN ('SSCC','ALT_HANDLING_UNIT_LABEL_ID')) THEN
            column_value_nullable_ := TRUE;
         ELSIF (data_item_id_ = 'HANDLING_UNIT_ID' AND data_item_value_ > 0) THEN
            Handling_Unit_API.Exist(data_item_value_);
         END IF;
   
         IF (data_item_id_ = 'SERIAL_NO' AND component_part_no_ IS NOT NULL AND serial_no_ IS NOT NULL AND
             part_catalog_rec_.receipt_issue_serial_track = Fnd_Boolean_API.DB_TRUE ) THEN
            -- Validate all serial handled parts
            Temporary_Part_Tracking_API.Validate_Serial(contract_, component_part_no_, serial_no_);
         END IF;
   
         qty_reserved_ := Shop_Material_Alloc_API.Get_Qty_Assigned(order_no_, release_no_, sequence_no_, line_item_no_);
   
         IF (qty_reserved_ > 0) THEN
            -- RESERVED: Check unique towards the reservation
            IF (Part_Catalog_API.Serial_Tracked_Only_Rece_Issue(component_part_no_)) THEN
               IF (Inventory_Part_In_Stock_API.Check_Individual_Exist(component_part_no_, serial_no_) = 1) THEN
                  -- Use scanned serial, since the part is identified as a serial even though it is just rcpt and issue tracked
                  filter_serial_no_ := serial_no_;
               ELSE
                  -- Use '*' as serial since serial is not identified
                  IF (data_item_id_ = 'SERIAL_NO') THEN
                     Part_Serial_Catalog_API.Exist(component_part_no_, serial_no_);
                     column_value_exist_check_ := FALSE; -- NOTE: Do not check column_name_ and column_value_ for serial no.
                  END IF;
                  IF (Part_Catalog_API.Serial_Tracked_Only_Rece_Issue(component_part_no_) AND
                      NOT Fnd_Boolean_API.Is_True_Db(Part_Serial_Catalog_API.Get_Tracked_In_Inventory_Db(component_part_no_, serial_no_))) THEN
                     filter_serial_no_ := '*';
                  ELSE
                     filter_serial_no_ := serial_no_;
                  END IF;
               END IF;
               Shop_Material_Assign_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                       order_no_                   => order_no_,
                                                                       release_no_                 => release_no_,
                                                                       sequence_no_                => sequence_no_,
                                                                       line_item_no_               => line_item_no_,
                                                                       part_no_                    => component_part_no_,
                                                                       location_no_                => location_no_,
                                                                       eng_chg_level_              => eng_chg_level_,
                                                                       activity_seq_               => activity_seq_,
                                                                       handling_unit_id_           => handling_unit_id_,
                                                                       alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                       lot_batch_no_               => lot_batch_no_,
                                                                       serial_no_                  => filter_serial_no_,
                                                                       configuration_id_           => configuration_id_,
                                                                       waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                       column_name_                => data_item_id_,
                                                                       column_value_               => data_item_value_,
                                                                       column_description_         => data_item_description_,
                                                                       column_value_exist_check_   => column_value_exist_check_,
                                                                       column_value_nullable_      => column_value_nullable_);
            ELSE
               -- Inv tracked or not tracked
               -- Use entered serial as serial (can be '*' for non tracked parts)
               Inv_Part_Stock_Reservation_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                             order_no_                   => order_no_,
                                                                             line_no_                    => release_no_,
                                                                             release_no_                 => sequence_no_,
                                                                             line_item_no_               => line_item_no_,
                                                                             part_no_                    => component_part_no_,
                                                                             configuration_id_           => configuration_id_,
                                                                             location_no_                => location_no_,
                                                                             lot_batch_no_               => lot_batch_no_,
                                                                             serial_no_                  => serial_no_,
                                                                             eng_chg_level_              => eng_chg_level_,
                                                                             waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                             activity_seq_               => activity_seq_,
                                                                             handling_unit_id_           => handling_unit_id_,
                                                                             alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                             column_name_                => data_item_id_,
                                                                             column_value_               => data_item_value_,
                                                                             column_description_         => data_item_description_,
                                                                             column_value_nullable_      => column_value_nullable_);
            END IF;
         ELSE
            -- NOT RESERVED: Check unique towards the inventory part in stock
            IF (Part_Catalog_API.Serial_Tracked_Only_Rece_Issue(component_part_no_)) THEN
               IF (Inventory_Part_In_Stock_API.Check_Individual_Exist(component_part_no_, serial_no_) = 1) THEN
                  sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
                  -- Use scanned serial, since the part is identified as a serial even though it is just rcpt and issue tracked
                  Inventory_Part_In_Stock_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                             part_no_                    => component_part_no_,
                                                                             configuration_id_           => configuration_id_,
                                                                             location_no_                => location_no_,
                                                                             lot_batch_no_               => lot_batch_no_,
                                                                             serial_no_                  => serial_no_,
                                                                             eng_chg_level_              => eng_chg_level_,
                                                                             waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                             activity_seq_               => activity_seq_,
                                                                             handling_unit_id_           => handling_unit_id_,
                                                                             alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                             column_name_                => data_item_id_,
                                                                             column_value_               => data_item_value_,
                                                                             column_description_         => data_item_description_,
                                                                             sql_where_expression_       => sql_where_expression_,
                                                                             column_value_nullable_      => column_value_nullable_);
               ELSE
                  IF (data_item_id_ = 'SERIAL_NO') THEN
                     Part_Serial_Catalog_API.Exist(component_part_no_, serial_no_);
                     sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
                     Inventory_Part_In_Stock_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                                part_no_                    => component_part_no_,
                                                                                configuration_id_           => configuration_id_,
                                                                                location_no_                => location_no_,
                                                                                lot_batch_no_               => lot_batch_no_,
                                                                                serial_no_                  => '*', -- Use '*' as serial since serial is not identified
                                                                                eng_chg_level_              => eng_chg_level_,
                                                                                waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                                activity_seq_               => activity_seq_,
                                                                                handling_unit_id_           => handling_unit_id_,
                                                                                alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                                column_name_                => data_item_id_,
                                                                                column_value_               => data_item_value_,
                                                                                column_description_         => data_item_description_,
                                                                                sql_where_expression_       => sql_where_expression_,
                                                                                column_value_exist_check_   => FALSE);  -- NOTE: we dont want to validate the column value here, just the rest of the keys
                  ELSE
                     sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
                     Inventory_Part_In_Stock_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                                part_no_                    => component_part_no_,
                                                                                configuration_id_           => configuration_id_,
                                                                                location_no_                => location_no_,
                                                                                lot_batch_no_               => lot_batch_no_,
                                                                                serial_no_                  => '*', -- Use '*' as serial since serial is not identified
                                                                                eng_chg_level_              => eng_chg_level_,
                                                                                waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                                activity_seq_               => activity_seq_,
                                                                                handling_unit_id_           => handling_unit_id_,
                                                                                alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                                column_name_                => data_item_id_,
                                                                                column_value_               => data_item_value_,
                                                                                column_description_         => data_item_description_,
                                                                                sql_where_expression_       => sql_where_expression_,
                                                                                column_value_nullable_      => column_value_nullable_);
                  END IF;
               END IF;
            ELSE
               sql_where_expression_ := Get_Sql_Where_Expression___(order_no_, release_no_, sequence_no_, line_item_no_);
               -- Inv tracked or not tracked
               -- Use entered serial as serial (can be '*' for non tracked parts)
               Inventory_Part_In_Stock_API.Record_With_Column_Value_Exist(contract_                   => contract_,
                                                                          part_no_                    => component_part_no_,
                                                                          configuration_id_           => configuration_id_,
                                                                          location_no_                => location_no_,
                                                                          lot_batch_no_               => lot_batch_no_,
                                                                          serial_no_                  => serial_no_,
                                                                          eng_chg_level_              => eng_chg_level_,
                                                                          waiv_dev_rej_no_            => waiv_dev_rej_no_,
                                                                          activity_seq_               => activity_seq_,
                                                                          handling_unit_id_           => handling_unit_id_,
                                                                          alt_handling_unit_label_id_ => alt_handling_unit_label_id_,
                                                                          column_name_                => data_item_id_,
                                                                          column_value_               => data_item_value_,
                                                                          column_description_         => data_item_description_,
                                                                          sql_where_expression_       => sql_where_expression_,
                                                                          column_value_nullable_      => column_value_nullable_);
            END IF;
         END IF;
      $ELSE
         NULL;
      $END
   END Core;

BEGIN
   Core(contract_, order_no_, release_no_, sequence_no_, line_item_no_, component_part_no_, location_no_, lot_batch_no_, serial_no_, eng_chg_level_, waiv_dev_rej_no_, configuration_id_, activity_seq_, handling_unit_id_, alt_handling_unit_label_id_, data_item_id_, data_item_value_, capture_session_id_);
END Validate_Data_Item___;


FUNCTION Get_Sql_Where_Expression___ (
   order_no_                 IN VARCHAR2,
   release_no_               IN VARCHAR2,
   sequence_no_              IN VARCHAR2,
   line_item_no_             IN NUMBER,
   unique_type_              IN VARCHAR2 DEFAULT 'NORMAL' ) RETURN VARCHAR2
IS
   
   FUNCTION Core (
      order_no_                 IN VARCHAR2,
      release_no_               IN VARCHAR2,
      sequence_no_              IN VARCHAR2,
      line_item_no_             IN NUMBER,
      unique_type_              IN VARCHAR2 DEFAULT 'NORMAL' ) RETURN VARCHAR2
   IS
      sql_where_expression_   VARCHAR2(2000);
      so_project_id_          VARCHAR2(10);
      supply_code_db_         VARCHAR2(50);
      so_condition_code_      VARCHAR2(10);
      qty_reserved_           NUMBER;
   BEGIN
   
      sql_where_expression_  := ' AND location_type_db IN (''PICKING'',''F'',''SHIPMENT'',''MANUFACTURING'')
                                  AND freeze_flag_db <> ''Y'' ';
   
      IF (order_no_ IS NOT NULL AND release_no_ IS NOT NULL AND sequence_no_ IS NOT NULL AND line_item_no_ IS NOT NULL) THEN
         qty_reserved_ := Shop_Material_Alloc_API.Get_Qty_Assigned(order_no_, release_no_, sequence_no_, line_item_no_);
   
         IF (unique_type_ = 'SERIAL_TRACKED_ONLY_RECE_ISSUE') THEN
            IF (qty_reserved_ > 0) THEN
               sql_where_expression_ := sql_where_expression_ || ' AND qty_onhand > 0
                                                                   AND serial_no != ''*'' ';
            ELSE  -- Nothing reserved
               sql_where_expression_ := sql_where_expression_ || ' AND (qty_onhand - qty_reserved) > 0
                                                                   AND serial_no != ''*'' ';
            END IF;
         ELSE  -- unique_type_ = 'NORMAL'
            sql_where_expression_  := sql_where_expression_  ||
            '  AND qty_onhand > 0
               AND ((' || qty_reserved_ || ' = 0
                    AND (qty_reserved = 0 ) OR (qty_reserved > 0 and qty_onhand - qty_reserved > 0))
                    OR Shop_Material_Assign_API.Check_Allocation_Assign_Loc('''||order_no_||''', '''||release_no_||''', '''||sequence_no_||''', ' || line_item_no_ || ' , location_no, lot_batch_no, serial_no, eng_chg_level, waiv_dev_rej_no, handling_unit_id) = 1) ';
         END IF;
   
         -- Add condition code filtering
         so_condition_code_ := Shop_Material_Alloc_API.Get_Condition_Code(order_no_, release_no_, sequence_no_, line_item_no_);
         IF (so_condition_code_ IS NOT NULL) THEN
            -- compare inventory stock record condition code with so condition code
            sql_where_expression_  := sql_where_expression_  || ' AND condition_code = ''' || so_condition_code_ || ''' ';
         ELSE
            sql_where_expression_  := sql_where_expression_  || ' AND condition_code IS NULL ';
         END IF;
   
         -- Add project filtering depending on the supply code (copied from similar functionality in frmAlloc.cs)
         so_project_id_ := Shop_Material_Alloc_API.Get_Project_Id(order_no_, release_no_, sequence_no_, line_item_no_);
         supply_code_db_ := Shop_Material_Alloc_API.Get_Supply_Code_Db(order_no_, release_no_, sequence_no_, line_item_no_);
         IF (so_project_id_ IS NULL OR supply_code_db_ = Order_Supply_Type_API.DB_INVENT_ORDER) THEN
            sql_where_expression_  := sql_where_expression_  || ' AND project_id IS NULL ';
         ELSE
            -- compare inventory stock record project id with so project id
            sql_where_expression_  := sql_where_expression_  || ' AND project_id = ''' || so_project_id_ || ''' ';
         END IF;
   
      ELSE
         sql_where_expression_  := sql_where_expression_  || ' AND qty_onhand > 0 ';
      END IF;
   
      RETURN sql_where_expression_;
   END Core;

BEGIN
   RETURN Core(order_no_, release_no_, sequence_no_, line_item_no_, unique_type_);
END Get_Sql_Where_Expression___;


FUNCTION Get_Input_Uom_Sql_Whr_Exprs___  RETURN VARCHAR2
IS
   
   FUNCTION Core  RETURN VARCHAR2
   IS
      sql_where_expression_   VARCHAR2(32000);
   BEGIN   
      sql_where_expression_  := ' AND (purch_usage_allowed = 1 OR cust_usage_allowed = 1 OR manuf_usage_allowed = 1) ';  
      RETURN sql_where_expression_;
   END Core;

BEGIN
   RETURN Core;
END Get_Input_Uom_Sql_Whr_Exprs___;