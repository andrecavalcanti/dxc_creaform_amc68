tableextension 50022 "DXCAsmToOrderLinkExt" extends "Assemble-to-Order Link" //MyTargetTableId
{
    fields
    {
        
    }

    var
        AsmHeaderDXC : Record "Assembly Header";
        Text003 : TextConst
           Comment='%1 = Document Type, %2 = No.',
          ENU='The item tracking defined on Assembly Header with Document Type %1, No. %2 exceeds %3 on Sales Line with Document Type %4, Document No. %5, Line No. %6.\\ You must adjust the existing item tracking before you can reenter the new quantity.',
          ESM='El seguimiento de productos definido en la cabecera de ensamblado con el tipo de documento %1, Nº %2 excede %3 en la línea de ventas con el tipo de documento %4, Nº documento %5, Nº línea %6.\\ Debe ajustar el seguim. prod. actual antes de volver a introducir la nueva cantidad.',
          FRC='La traçabilité définie sur l''en-tête d''assemblage avec le type document %1 et le n° %2 dépasse %3 sur la ligne vente avec le type document %4, le n° document %5 et le n° ligne %6.\\ Vous devez ajuster cette traçabilité avant de pouvoir entrer de nouveau la nouvelle quantité.',
          ENC='The item tracking defined on Assembly Header with Document Type %1, No. %2 exceeds %3 on Sales Line with Document Type %4, Document No. %5, Line No. %6.\\ You must adjust the existing item tracking before you can reenter the new quantity.';
    [Scope('Personalization')]
    procedure UpdateAsmFromSalesLineDXC(var NewSalesLine : Record "Sales Line");
    begin
        UpdateAsmDXC(NewSalesLine,AsmExistsForSalesLine(NewSalesLine));
    end;

    local procedure UpdateAsmDXC(var NewSalesLine : Record "Sales Line";AsmExists : Boolean);
    var
        SalesLine2 : Record "Sales Line";
        InvtAdjmtEntryOrder : Record "Inventory Adjmt. Entry (Order)";
    begin
        if AsmExists then begin
          if not NewSalesLine.IsAsmToOrderAllowed then begin
            DeleteAsmFromSalesLine(NewSalesLine);
            exit;
          end;
          if NewSalesLine."Qty. to Assemble to Stock" = 0 then begin
            DeleteAsmFromSalesLine(NewSalesLine);
            InvtAdjmtEntryOrder.SETRANGE("Order Type",InvtAdjmtEntryOrder."Order Type"::Assembly);
            InvtAdjmtEntryOrder.SETRANGE("Order No.","Assembly Document No.");
            if ("Assembly Document Type" <> "Assembly Document Type"::Order) or not InvtAdjmtEntryOrder.ISEMPTY then
              INSERT;
            exit;
          end;
          if not GetAsmHeaderDXC then begin
            DELETE;
            InsertAsmHeader(AsmHeaderDXC,"Assembly Document Type","Assembly Document No.");
          end else begin
            if not NeedsSynchronization(NewSalesLine) then
              exit;
            AsmReopenIfReleased;
            DELETE;
          end;
        end else begin
          if NewSalesLine."Qty. to Assemble to Stock" = 0 then
            exit;
          if not SalesLine2.GET(NewSalesLine."Document Type",NewSalesLine."Document No.",NewSalesLine."Line No.") then
            exit;

          InsertAsmHeader(AsmHeaderDXC,NewSalesLine."Document Type",'');

          "Assembly Document Type" := AsmHeaderDXC."Document Type";
          "Assembly Document No." := AsmHeaderDXC."No.";
          Type := Type::Sale;
          "Document Type" := NewSalesLine."Document Type";
          "Document No." := NewSalesLine."Document No.";
          "Document Line No." := NewSalesLine."Line No.";
        end;

        SynchronizeAsmFromSalesLineDXC(NewSalesLine);
        INSERT;
        AsmHeaderDXC."Shortcut Dimension 1 Code" := NewSalesLine."Shortcut Dimension 1 Code";
        AsmHeaderDXC."Shortcut Dimension 2 Code" := NewSalesLine."Shortcut Dimension 2 Code";
        AsmHeaderDXC.MODIFY(true);

        //OnAfterUpdateAsm(AsmHeader);
    end;

    [Scope('Personalization')]
    procedure SynchronizeAsmFromSalesLineDXC(var NewSalesLine : Record "Sales Line");
    var
        TempTrackingSpecification : Record "Tracking Specification" temporary;
        SalesHeader : Record "Sales Header";
        Window : Dialog;
        QtyTracked : Decimal;
        QtyTrackedBase : Decimal;
    begin
        GetAsmHeaderDXC;

        Window.OPEN(GetWindowOpenTextSale(NewSalesLine));

        CaptureItemTracking(TempTrackingSpecification,QtyTracked,QtyTrackedBase);

        if NewSalesLine."Qty. to Asm. to Stock (Base)" < QtyTrackedBase then
          ERROR(Text003,
            AsmHeaderDXC."Document Type",
            AsmHeaderDXC."No.",
            NewSalesLine.FIELDCAPTION("Qty. to Assemble to Stock"),
            NewSalesLine."Document Type",
            NewSalesLine."Document No.",
            NewSalesLine."Line No.");

        UnreserveAsmDXC;

        SalesHeader.GET(NewSalesLine."Document Type",NewSalesLine."Document No.");
        AsmHeaderDXC.SetWarningsOff;
        ChangeItemDXC(NewSalesLine."No.");
        ChangeLocationDXC(NewSalesLine."Location Code");
        ChangeVariantDXC(NewSalesLine."Variant Code");
        ChangeBinCodeDXC(NewSalesLine."Bin Code");
        ChangeUOMDXC(NewSalesLine."Unit of Measure Code");
        ChangeDateDXC(NewSalesLine."Shipment Date");
        ChangePostingDateDXC(SalesHeader."Posting Date");
        ChangeDimDXC(NewSalesLine."Dimension Set ID");
        ChangePlanningFlexibilityDXC;
        ChangeQtyDXC(NewSalesLine."Qty. to Assemble to Stock");
        if NewSalesLine."Document Type" <> NewSalesLine."Document Type"::Quote then
          ChangeQtyToAsmDXC(MaxQtyToAsm(NewSalesLine,AsmHeaderDXC));

        AsmHeaderDXC.MODIFY(true);

        ReserveAsmToSaleDXC(NewSalesLine,
          AsmHeaderDXC."Remaining Quantity" - QtyTracked,
          AsmHeaderDXC."Remaining Quantity (Base)" - QtyTrackedBase);
        RestoreItemTracking(TempTrackingSpecification,NewSalesLine);

        NewSalesLine.CheckAsmToOrderDXC(AsmHeaderDXC);
        Window.CLOSE;

        AsmHeaderDXC.ShowDueDateBeforeWorkDateMsg;
    end;

    [Scope('Personalization')]
    procedure ShowAsmToOrderLinesDXC(SalesLine : Record "Sales Line");
    var
        AsmLine : Record "Assembly Line";
    begin
        SalesLine.TESTFIELD("Qty. to Asm. to Stock (Base)");
        if AsmExistsForSalesLine(SalesLine) then begin
          AsmLine.FILTERGROUP := 2;
          AsmLine.SETRANGE("Document Type","Assembly Document Type");
          AsmLine.SETRANGE("Document No.","Assembly Document No.");
          AsmLine.FILTERGROUP := 0;
          PAGE.RUNMODAL(PAGE::"Assemble-to-Order Lines",AsmLine);
        end;
    end;
    
    procedure GetAsmHeaderDXC() : Boolean;
    begin
        if (AsmHeaderDXC."Document Type" = "Assembly Document Type") and
           (AsmHeaderDXC."No." = "Assembly Document No.")
        then
          exit(true);
        exit(AsmHeaderDXC.GET("Assembly Document Type","Assembly Document No."));
    end;
    
    [Scope('Personalization')]
    procedure ChangeItemDXC(NewItemNo : Code[20]);
    begin
        if AsmHeaderDXC."Item No." = NewItemNo then
          exit;

        AsmHeaderDXC.VALIDATE("Item No.",NewItemNo);
    end;

    [Scope('Personalization')]
    procedure ChangeQtyDXC(NewQty : Decimal);
    begin
        if AsmHeaderDXC.Quantity = NewQty then
          exit;

        AsmHeaderDXC.VALIDATE(Quantity,NewQty);
    end;

    [Scope('Personalization')]
    procedure ChangeQtyToAsmDXC(NewQtyToAsm : Decimal) : Boolean;
    begin
        if AsmHeaderDXC."Quantity to Assemble" = NewQtyToAsm then
          exit(false);

        AsmHeaderDXC.VALIDATE("Quantity to Assemble",NewQtyToAsm);
        exit(true)
    end;

    [Scope('Personalization')]
    procedure ChangeLocationDXC(NewLocation : Code[10]);
    begin
        if AsmHeaderDXC."Location Code" = NewLocation then
          exit;

        AsmHeaderDXC.VALIDATE("Location Code",NewLocation);
    end;

    [Scope('Personalization')]
    procedure ChangeVariantDXC(NewVariant : Code[10]);
    begin
        if AsmHeaderDXC."Variant Code" = NewVariant then
          exit;

        AsmHeaderDXC.VALIDATE("Variant Code",NewVariant);
    end;

    [Scope('Personalization')]
    procedure ChangeUOMDXC(NewUOMCode : Code[10]);
    begin
        if AsmHeaderDXC."Unit of Measure Code" = NewUOMCode then
          exit;

        AsmHeaderDXC.VALIDATE("Unit of Measure Code",NewUOMCode);
    end;

    [Scope('Personalization')]
    procedure ChangeDateDXC(NewDate : Date);
    begin
        if AsmHeaderDXC."Due Date" = NewDate then
          exit;

        AsmHeaderDXC.VALIDATE("Due Date",NewDate);
    end;

    [Scope('Personalization')]
    procedure ChangePostingDateDXC(NewDate : Date);
    begin
        if AsmHeaderDXC."Posting Date" = NewDate then
          exit;

        AsmHeaderDXC.VALIDATE("Posting Date",NewDate);
    end;

    [Scope('Personalization')]
    procedure ChangeDimDXC(NewDimSetID : Integer) : Boolean;
    begin
        if AsmHeaderDXC."Dimension Set ID" = NewDimSetID then
          exit(false);

        AsmHeaderDXC.VALIDATE("Dimension Set ID",NewDimSetID);
        exit(true)
    end;

    [Scope('Personalization')]
    procedure ChangeBinCodeDXC(NewBinCode : Code[20]) : Boolean;
    begin
        if AsmHeaderDXC."Bin Code" = NewBinCode then
          exit(false);

        AsmHeaderDXC.ValidateBinCode(NewBinCode);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ChangePlanningFlexibilityDXC();
    begin
        if AsmHeaderDXC."Planning Flexibility" = AsmHeaderDXC."Planning Flexibility"::None then
          exit;

        AsmHeaderDXC.VALIDATE("Planning Flexibility",AsmHeaderDXC."Planning Flexibility"::None);
    end;   

      [Scope('Personalization')]
    procedure ReserveAsmToSaleDXC(var SalesLine : Record "Sales Line";QtyToReserve : Decimal;QtyToReserveBase : Decimal);
    var
        ReservEntry : Record "Reservation Entry";
        TrackingSpecification : Record "Tracking Specification";
        AsmHeaderReserve : Codeunit "Assembly Header-Reserve";
    begin
        if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
          exit;

        if Type = Type::Sale then begin
          GetAsmHeaderDXC;

          AsmHeaderReserve.SetBinding(ReservEntry.Binding::"Order-to-Order");
          AsmHeaderReserve.SetDisallowCancellation(true);
          TrackingSpecification.InitTrackingSpecification2(
            DATABASE::"Sales Line",SalesLine."Document Type",SalesLine."Document No.",'',0,SalesLine."Line No.",
            AsmHeaderDXC."Variant Code",AsmHeaderDXC."Location Code",AsmHeaderDXC."Qty. per Unit of Measure");
          AsmHeaderReserve.CreateReservationSetFrom(TrackingSpecification);
          AsmHeaderReserve.CreateReservation2(AsmHeaderDXC,AsmHeaderDXC.Description,AsmHeaderDXC."Due Date",QtyToReserve,QtyToReserveBase);

          if SalesLine.Reserve = SalesLine.Reserve::Never then
            SalesLine.Reserve := SalesLine.Reserve::Optional;
        end;
    end;

    [Scope('Personalization')]
    procedure UnreserveAsmDXC();
    var
        ReservEntry : Record "Reservation Entry";
        AsmHeaderReserve : Codeunit "Assembly Header-Reserve";
    begin
        GetAsmHeaderDXC;

        AsmHeaderReserve.FilterReservFor(ReservEntry,AsmHeaderDXC);
        AsmHeaderReserve.DeleteLine(AsmHeaderDXC);
    end;
    
}