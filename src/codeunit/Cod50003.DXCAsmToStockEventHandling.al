codeunit 50003 "DXCAsmToStockEventHandling"
{
     //---T37---
    [EventSubscriber(ObjectType::Table, 37, 'BeforeCheckAsmToOrder', '', false, false)]
    local procedure HandleBeforeCheckAsmToOrder(var SalesLine : Record "Sales Line"; AssembleToStock : Boolean);
    begin
        if SalesLine."Qty. to Assemble to Stock" <> 0 then
            AssembleToStock   := true;  
    end;
}