codeunit 50003 "DXCAsmToStockEventHandling"
{
     //---T37---
   /*  [EventSubscriber(ObjectType::Table, 37, 'BeforeCheckAsmToOrder', '', false, false)]
    local procedure HandleBeforeCheckAsmToOrder(var SalesLine : Record "Sales Line"; var AssembleToStock : Boolean);
    begin
        if SalesLine."Qty. to Assemble to Stock" <> 0 then
            AssembleToStock   := true;         
    end;    */
    
    [EventSubscriber(ObjectType::Table, 900, 'IsAsmToStock', '', false, false)]
    local procedure HandleIsAsmToStockOnAsmHeader(AssemblyHeader : Record "Assembly Header"; var AsmToStock : Boolean);
    begin
        if AssemblyHeader."Assembly To Stock" then
            AsmToStock := true;           
    end;    
}