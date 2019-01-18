pageextension 50031 "DXCSalesOrderExt" extends "Sales Order" //MyTargetPageId
{
    layout
    {
        
    }
    
    actions
    {
        addafter(AssemblyOrders)
        {
            action(AssemblyOrdersToStock)
            {
                AccessByPermission = TableData "BOM Component"=R;
                ApplicationArea = Assembly;
                CaptionML = ENU='Assembly Orders To Stock',
                            ESM='Pedidos de ensamblado',
                            FRC='Ordres d''assemblage',
                            ENC='Assembly Orders To Stock';
                Image = AssemblyOrder;
                RunObject = Page "Assembly Orders";
                RunPageLink = "Document Type"=CONST(Order),
                                "Sales Order No."=FIELD("No.");
                ToolTipML = ENU='View ongoing assembly orders related to the sales order. ',
                            ESM='Permite ver pedidos de ensamblado en curso relacionados con el pedido de ventas. ',
                            FRC='Affichez les ordres d''assemblage en cours associés au document de vente. ',
                            ENC='View ongoing assembly orders related to the sales order. ';
                
            }
        }
    
    }
}