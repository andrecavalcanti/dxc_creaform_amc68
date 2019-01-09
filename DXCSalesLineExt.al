tableextension 50021 DXCSalesLineExt extends "Sales Line" //MyTargetTableId
{
      fields
    {
        // Add changes to table fields here
        // >> AMC-68
        field(50000; "Qty. to Assemble to Stock"; Decimal)
        {
           BlankZero = true; 

           trigger OnValidate();
            var
                SalesLineReserve : Codeunit "Sales Line-Reserve";
            begin
                // DXC
                WhseValidateSourceLine.SalesLineVerifyChange(Rec,xRec);

                "Qty. to Asm. to Stock (Base)" := CalcBaseQty("Qty. to Assemble to Stock");

                if "Qty. to Asm. to Stock (Base)" <> 0 then begin
                  Rec.TESTFIELD("Drop Shipment",false);
                  Rec.TESTFIELD("Special Order",false);
                  if "Qty. to Asm. to Stock (Base)" < 0 then
                    FIELDERROR("Qty. to Assemble to Stock",STRSUBSTNO(Text009,FIELDCAPTION("Quantity (Base)"),"Quantity (Base)"));
                  Rec.TESTFIELD("Appl.-to Item Entry",0);

                  case "Document Type" of
                    "Document Type"::"Blanket Order",
                    "Document Type"::Quote:
                      if ("Quantity (Base)" = 0) or ("Qty. to Asm. to Stock (Base)" <= 0) or SalesLineReserve.ReservEntryExist(Rec) then
                        Rec.TESTFIELD("Qty. to Asm. to Stock (Base)",0)
                      else
                        if "Quantity (Base)" <> "Qty. to Asm. to Stock (Base)" then
                          FIELDERROR("Qty. to Assemble to Stock",STRSUBSTNO(Text031,0,"Quantity (Base)"));
                    "Document Type"::Order:
                      ;
                    else
                      Rec.TESTFIELD("Qty. to Asm. to Stock (Base)",0);
                  end;
                end;

                CheckItemAvailable(FIELDNO("Qty. to Assemble to Stock"));
                if not (CurrFieldNo in [FIELDNO(Quantity),FIELDNO("Qty. to Assemble to Stock")]) then
                  GetDefaultBin;
                AutoAsmToOrderDXC;
            end;
           
        }
        // << AMC-68

        field(50001; "Qty. to Asm. to Stock (Base)"; Decimal)
        {
            trigger OnValidate();
            begin
                Rec.TESTFIELD("Qty. per Unit of Measure",1);
                VALIDATE("Qty. to Assemble to Stock","Qty. to Asm. to Stock (Base)");
            end;
        }

        // >> AMC-63
        field(50002; "ATS Whse. Outstanding Qty"; Decimal)
        {
            
        }

        field(50003; "ATS Whse. Outstanding Qty (Base)"; Decimal)
        {
            
        }

        field(50004; "Hidden On Invoice"; Boolean)
        {
            
        }
        
        field(50005; "Visible Unit Price"; Decimal)
        {
            
        }
        
        field(50006; "CRM Line Number"; Integer)
        {
            
        }
        
        field(50007; "List Price"; Decimal)
        {
           
        }
        
        field(50008; "RMA Serial Number";  Text[50])
        {
            
        }

        field(50009; "To Be Supplied By"; Text[20])
        {
            
        }
        // << AMC-63
        
        
    }  
    var
        WhseValidateSourceLine : Codeunit "Whse. Validate Source Line";
        ATOLink : Record "Assemble-to-Order Link";
        Text009 : TextConst ENU=' must be 0 when %1 is %2',ESM=' debe ser 0 cuando %1 es %2',FRC=' doit être 0 lorsque %1 est %2',ENC=' must be 0 when %1 is %2';
        Text031 : TextConst ENU='You must either specify %1 or %2.',ESM='Debe especificar %1 o %2.',FRC='Vous devez spécifier %1 ou %2.',ENC='You must either specify %1 or %2.';
        Text045 : TextConst ENU='cannot be more than %1',ESM='no puede ser superior a %1',FRC='ne peut être supérieur à %1',ENC='cannot be more than %1';
    [Scope('Personalization')]
    procedure AutoAsmToOrderDXC();
    begin
        ATOLink.UpdateAsmFromSalesLineDXC(Rec);
    end;

    [Scope('Personalization')]
    procedure CheckAsmToOrderDXC(AsmHeader : Record "Assembly Header");
    begin
        Rec.TESTFIELD("Qty. to Assemble to Stock",AsmHeader.Quantity);
        Rec.TESTFIELD("Document Type",AsmHeader."Document Type");
        Rec.TESTFIELD(Type,Type::Item);
        Rec.TESTFIELD("No.",AsmHeader."Item No.");
        Rec.TESTFIELD("Location Code",AsmHeader."Location Code");
        Rec.TESTFIELD("Unit of Measure Code",AsmHeader."Unit of Measure Code");
        Rec.TESTFIELD("Variant Code",AsmHeader."Variant Code");
        Rec.TESTFIELD("Shipment Date",AsmHeader."Due Date");
        if "Document Type" = "Document Type"::Order then begin
          AsmHeader.CALCFIELDS("Reserved Qty. (Base)");
          AsmHeader.TESTFIELD("Reserved Qty. (Base)",AsmHeader."Remaining Quantity (Base)");
        end;
        Rec.TESTFIELD("Qty. to Asm. to Stock (Base)",AsmHeader."Quantity (Base)");
        if "Outstanding Qty. (Base)" < AsmHeader."Remaining Quantity (Base)" then
          AsmHeader.FIELDERROR("Remaining Quantity (Base)",STRSUBSTNO(Text045,AsmHeader."Remaining Quantity (Base)"));
    end;

    [Scope('Personalization')]
    procedure ShowAsmToOrderLinesDXC();
    var
        ATOLink : Record "Assemble-to-Order Link";
    begin
        ATOLink.ShowAsmToOrderLinesDXC(Rec);
    end;
    
}