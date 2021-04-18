%dw 2.0
				
import java!java::util::concurrent::atomic::AtomicInteger
var counter = AtomicInteger::new(0)
fun increment() = Java::invoke('java.util.concurrent.atomic.AtomicInteger', 'incrementAndGet()', counter, {})
fun dateIdQualifier (val : String ) = if (val == "004") "Purchase Order" 
                                       else 
                                      if(val == "015") "Promotion Start" 
                                           else 
                                      if(val == "016") "Promotion End" 
                                           else ""  
                                           
fun referenceId (val : String ) = if (val == "PO") "Purchase Order Number" 
                                       else 
                                      if(val == "ZZ") "Mutually Defined" 
                                           else ""
                                           
fun activityCode (val : String ) = if (val == "QA") "Current Inventory (Onhand)" 
                                       else 
                                      if(val == "QD") "Additional Demand by Date" 
                                           else 
                                       if(val == "QO") "Out of Stocks" 
                                         else 
                                       if(val == "QP") "On Order by PO" 
                                         else 
                                        if(val == "QS") "Turn or Combined Sales" 
                                           else 
                                        if(val == "QT") "Promotiona Sales" 
                                           else ""       

output application/csv  separator=",", quoteValues=true


---

 flatten (payload."TransactionSets"."v004010"."852"[0]."Detail"."010_LIN_Loop" map using (parentVal = $) (
       
        $."080_ZA_Loop" map (( innerVal,ind) -> {

       // "Level" : "HEADERS",
		"Transaction_date" : vars.vars_headers."020_XQ"."XQ02"  as Date,
		"Ship_To_Name" :  if (vars.vars_headers."060_N1_Loop"[0]."060_N1"."N101" == "ST" ) ((vars.vars_headers."060_N1_Loop"[0]."060_N1"."N102") replace "\\" with "") as String else "",
		"Ship_To_DUNS_Number" : if (vars.vars_headers."060_N1_Loop"[0]."060_N1"."N101" == "ST" ) vars.vars_headers."060_N1_Loop"[0]."060_N1"."N104" as String else "",
		"Vendor_name" : if (vars.vars_headers."060_N1_Loop"[1]."060_N1"."N101" == "VN" ) ((vars.vars_headers."060_N1_Loop"[1]."060_N1"."N102") replace "\\" with "") as String else "",
		"Vendor_DUNS_Number" : if (vars.vars_headers."060_N1_Loop"[1]."060_N1"."N101" == "VN" ) vars.vars_headers."060_N1_Loop"[1]."060_N1"."N104" as String  else "",
		"Process_Date" : if (vars.vars_headers."060_N1_Loop"[1]."120_DTM"[0]."DTM01" == "009" ) vars.vars_headers."060_N1_Loop"[1]."120_DTM"[0]."DTM02" as Date else "",
		
		"Line_number" : increment(),
		"UPC_Case_codes" : if(parentVal."010_LIN"."LIN02" == "UA") parentVal."010_LIN"."LIN03"  else "",
		"Pack" : if(parentVal."030_PO4"."PO401" != null ) parentVal."030_PO4"."PO401"  else "",
		"Size" : if(parentVal."030_PO4"."PO402" != null ) parentVal."030_PO4"."PO402"  else "",
		"Unit_of_Measure" :if(parentVal."030_PO4"."PO403" != null ) parentVal."030_PO4"."PO403"  else "",
		
		"Activity_Code": if(innerVal."080_ZA"."ZA01" != null) activityCode(innerVal."080_ZA"."ZA01") else "",
		"Quantity" : if(innerVal."080_ZA"."ZA02" != null) innerVal."080_ZA"."ZA02" else "" ,
		"Unit_of_Measure_1" : if(innerVal."080_ZA"."ZA03" != null) innerVal."080_ZA"."ZA03" else "" ,
		"Date_ID_Qualifier" :if(innerVal."080_ZA"."ZA04" != null) dateIdQualifier(innerVal."080_ZA"."ZA04") else "" ,
		"Date" : if(innerVal."080_ZA"."ZA05" != null) innerVal."080_ZA"."ZA05" as Date else "" ,
		"Reference_ID": if(innerVal."080_ZA"."ZA06" != null) referenceId(innerVal."080_ZA"."ZA06") else "",
		"Reference": if(innerVal."080_ZA"."ZA07" != null) (innerVal."080_ZA"."ZA07") else ""
  } )
  
  ))
		
		
		
