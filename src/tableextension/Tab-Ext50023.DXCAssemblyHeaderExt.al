tableextension 50023 "DXCAssemblyHeaderExt" extends "Assembly Header" //MyTargetTableId
{
    fields
    {
        field(50000; "Assembly To Stock"; Boolean)
        {
            Caption = 'Assembly To Stock';
            DataClassification = ToBeClassified;
        }

        field(50001; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = ToBeClassified;
        }

        field(50002; "Sales Order Line No."; Integer)
        {
            Caption = 'Sales Order Line No.';
            DataClassification = ToBeClassified;
        }
        
        
        
    }
    
}