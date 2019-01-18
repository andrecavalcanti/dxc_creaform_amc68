pageextension 50028 "DXCSalesOrderSubformExt" extends "Sales Order Subform" //MyTargetPageId
{
    layout
    {
        // >> AMC-68
        addafter("Qty. to Assemble to Order")
        {
            field("Qty. to Assemble to Stock";"Qty. to Assemble to Stock")
            {
                ApplicationArea = All; 
                DecimalPlaces = 0:5;            
            }  

        }       
        // << AMC-68     
        
    }
    
    actions
    {
    }


}