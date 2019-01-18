codeunit 50003 "DXCAsmToStockEventHandling"
{
     //---T37---
   /*  [EventSubscriber(ObjectType::Table, 37, 'BeforeCheckAsmToOrder', '', false, false)]
    local procedure HandleBeforeCheckAsmToOrder(var SalesLine : Record "Sales Line"; var AssembleToStock : Boolean);
    begin
        if SalesLine."Qty. to Assemble to Stock" <> 0 then
            AssembleToStock   := true;         
    end;   
    
    [EventSubscriber(ObjectType::Table, 900, 'IsAsmToStock', '', false, false)]
    local procedure HandleIsAsmToStockOnAsmHeader(AssemblyHeader : Record "Assembly Header"; var AsmToStock : Boolean);
    begin
        if AssemblyHeader."Assembly To Stock" then
            AsmToStock := true;           
    end; 
    */

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Qty. to Assemble to Stock', false, false)]
    local procedure HandleAfterValidateAsmToStockOnSalesLine(var Rec : Record "Sales Line";var xRec : Record "Sales Line";CurrFieldNo : Integer);
    var
        SalesOrderAssembletoStock : Codeunit DXCSalesOrderAssembleToStock;
    begin

        if Rec."Qty. to Assemble to Stock" = 0 then
          SalesOrderAssembletoStock.DeleteAsmOrder(Rec)
        else
          SalesOrderAssembletoStock.RUN(Rec);
    end;   
}