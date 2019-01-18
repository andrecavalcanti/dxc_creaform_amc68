tableextension 50021 "DXCSalesLineExt" extends "Sales Line" //MyTargetTableId
{
    fields
    {
        // Add changes to table fields here
        // >> AMC-68
        field(50000; "Qty. to Assemble to Stock"; Decimal)
        {
           BlankZero = true;  
           DecimalPlaces = 0:5;        
           
        }
        // << AMC-68

        field(50001; "Qty. to Asm. to Stock (Base)"; Decimal)
        {
            DecimalPlaces = 0:5;
        }         
        
    }   
    
}