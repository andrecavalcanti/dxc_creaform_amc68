codeunit 50004 "DXCSalesOrderAssembleToStock"
{
    // version AMC-68

    TableNo = "Sales Line";

    trigger OnRun();
    begin


        InsertAsmHeader;
        SynchronizeAsmFromSalesLine(Rec);
        ReserveAsmToSale(Rec);
    end;

    var
        AsmHeader : Record "Assembly Header";

    local procedure CreateAssemblyOrder();
    var
        AsmHeader : Record "Assembly Header";
    begin
    end;

    procedure InsertAsmHeader();
    begin
        AsmHeader.INIT;
        AsmHeader.VALIDATE("Document Type",AsmHeader."Document Type"::Order);
        //AsmHeader.VALIDATE("No.",NewDocNo);
        AsmHeader.INSERT(true);
    end;

    local procedure SynchronizeAsmFromSalesLine(var NewSalesLine : Record "Sales Line");
    var
        TempTrackingSpecification : Record "Tracking Specification" temporary;
        SalesHeader : Record "Sales Header";
        Window : Dialog;
        QtyTracked : Decimal;
        QtyTrackedBase : Decimal;
    begin
        //GetAsmHeader;

        //Window.OPEN(GetWindowOpenTextSale(NewSalesLine));

        //CaptureItemTracking(TempTrackingSpecification,QtyTracked,QtyTrackedBase);

        // IF NewSalesLine."Qty. to Asm. to Order (Base)" < QtyTrackedBase THEN
        //  ERROR(Text003,
        //    AsmHeader."Document Type",
        //    AsmHeader."No.",
        //    NewSalesLine.FIELDCAPTION("Qty. to Assemble to Order"),
        //    NewSalesLine."Document Type",
        //    NewSalesLine."Document No.",
        //    NewSalesLine."Line No.");

        // UnreserveAsm;

        SalesHeader.GET(NewSalesLine."Document Type",NewSalesLine."Document No.");
        AsmHeader.SetWarningsOff;
        ChangeItem(NewSalesLine."No.");
        ChangeLocation(NewSalesLine."Location Code");
        ChangeVariant(NewSalesLine."Variant Code");
        ChangeBinCode(NewSalesLine."Bin Code");
        ChangeUOM(NewSalesLine."Unit of Measure Code");
        ChangeDate(NewSalesLine."Shipment Date");
        ChangePostingDate(SalesHeader."Posting Date");
        ChangeDim(NewSalesLine."Dimension Set ID");
        ChangePlanningFlexibility;
        ChangeQty(NewSalesLine."Qty. to Assemble to Stock");
        if NewSalesLine."Document Type" <> NewSalesLine."Document Type"::Quote then
          //ChangeQtyToAsm(MaxQtyToAsm(NewSalesLine,AsmHeader));
          ChangeQtyToAsm(NewSalesLine."Qty. to Assemble to Stock");

        AsmHeader."Sales Order No." := NewSalesLine."Document No.";
        AsmHeader."Sales Order Line No." := NewSalesLine."Line No.";

        AsmHeader.MODIFY(true);

        // ReserveAsmToSale(NewSalesLine,
        //  AsmHeader."Remaining Quantity" - QtyTracked,
        //  AsmHeader."Remaining Quantity (Base)" - QtyTrackedBase);
        // RestoreItemTracking(TempTrackingSpecification,NewSalesLine);

        //NewSalesLine.CheckAsmToOrder(AsmHeader);
        //Window.CLOSE;

        AsmHeader.ShowDueDateBeforeWorkDateMsg;
    end;

    local procedure ChangeItem(NewItemNo : Code[20]);
    begin
        if AsmHeader."Item No." = NewItemNo then
          exit;

        AsmHeader.VALIDATE("Item No.",NewItemNo);
    end;

    local procedure ChangeQty(NewQty : Decimal);
    begin
        if AsmHeader.Quantity = NewQty then
          exit;

        AsmHeader.VALIDATE(Quantity,NewQty);
    end;

    local procedure ChangeQtyToAsm(NewQtyToAsm : Decimal) : Boolean;
    begin
        if AsmHeader."Quantity to Assemble" = NewQtyToAsm then
          exit(false);

        AsmHeader.VALIDATE("Quantity to Assemble",NewQtyToAsm);
        exit(true)
    end;

    local procedure ChangeLocation(NewLocation : Code[10]);
    begin
        if AsmHeader."Location Code" = NewLocation then
          exit;

        AsmHeader.VALIDATE("Location Code",NewLocation);
    end;

    local procedure ChangeVariant(NewVariant : Code[10]);
    begin
        if AsmHeader."Variant Code" = NewVariant then
          exit;

        AsmHeader.VALIDATE("Variant Code",NewVariant);
    end;

    local procedure ChangeUOM(NewUOMCode : Code[10]);
    begin
        if AsmHeader."Unit of Measure Code" = NewUOMCode then
          exit;

        AsmHeader.VALIDATE("Unit of Measure Code",NewUOMCode);
    end;

    local procedure ChangeDate(NewDate : Date);
    begin
        if AsmHeader."Due Date" = NewDate then
          exit;

        AsmHeader.VALIDATE("Due Date",NewDate);
    end;

    local procedure ChangePostingDate(NewDate : Date);
    begin
        if AsmHeader."Posting Date" = NewDate then
          exit;

        AsmHeader.VALIDATE("Posting Date",NewDate);
    end;

    local procedure ChangeDim(NewDimSetID : Integer) : Boolean;
    begin
        if AsmHeader."Dimension Set ID" = NewDimSetID then
          exit(false);

        AsmHeader.VALIDATE("Dimension Set ID",NewDimSetID);
        exit(true)
    end;

    local procedure ChangeBinCode(NewBinCode : Code[20]) : Boolean;
    begin
        if AsmHeader."Bin Code" = NewBinCode then
          exit(false);

        AsmHeader.ValidateBinCode(NewBinCode);
        exit(true);
    end;

    local procedure ChangePlanningFlexibility();
    begin
        if AsmHeader."Planning Flexibility" = AsmHeader."Planning Flexibility"::None then
          exit;

        AsmHeader.VALIDATE("Planning Flexibility",AsmHeader."Planning Flexibility"::None);
    end;

    [Scope('Personalization')]
    procedure MaxQtyToAsm(SalesLine : Record "Sales Line";AssemblyHeader : Record "Assembly Header") : Decimal;
    begin
        //EXIT(GetMin(SalesLine."Qty. to Ship",AssemblyHeader."Remaining Quantity"));
    end;

    procedure ReserveAsmToSale(SalesLine : Record "Sales Line");
    var
        ReservEntry : Record "Reservation Entry";
        TrackingSpecification : Record "Tracking Specification";
        AsmHeaderReserve : Codeunit "Assembly Header-Reserve";
    begin
        if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
          exit;

        //IF Type = Type::Sale THEN BEGIN
        //  GetAsmHeader;

          //AsmHeaderReserve.SetBinding(ReservEntry.Binding::"Order-to-Order");
          //AsmHeaderReserve.SetDisallowCancellation(true);
          TrackingSpecification.InitTrackingSpecification2(
            DATABASE::"Sales Line",SalesLine."Document Type",SalesLine."Document No.",'',0,SalesLine."Line No.",
            AsmHeader."Variant Code",AsmHeader."Location Code",AsmHeader."Qty. per Unit of Measure");
          AsmHeaderReserve.CreateReservationSetFrom(TrackingSpecification);
        //  AsmHeaderReserve.CreateReservation2(AsmHeader,AsmHeader.Description,AsmHeader."Due Date",QtyToReserve,QtyToReserveBase);
          AsmHeaderReserve.CreateReservation2(AsmHeader,AsmHeader.Description,AsmHeader."Due Date",SalesLine."Qty. to Assemble to Stock",SalesLine."Qty. to Assemble to Stock");

        //  IF SalesLine.Reserve = SalesLine.Reserve::Never THEN
        //    SalesLine.Reserve := SalesLine.Reserve::Optional;
        //END;
        //MESSAGE('finished');
    end;

    [Scope('Personalization')]
    procedure DeleteAsmOrder(SalesLine : Record "Sales Line");
    begin

        if (SalesLine."Document No." = '') or (SalesLine."Line No." = 0) then
          exit;

        AsmHeader.SETRANGE("Sales Order No.",SalesLine."Document No.");
        AsmHeader.SETRANGE("Sales Order Line No.",SalesLine."Line No.");
        AsmHeader.DELETEALL(true);
    end;
}

