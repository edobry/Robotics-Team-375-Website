<%@ Control Language="C#" AutoEventWireup="true" CodeFile="profile.ascx.cs" Inherits="Controls_profile" %>

<asp:Repeater ID="rptProfile" runat="server" onitemdatabound="rptProfile_ItemDataBound">
    <ItemTemplate>
        <asp:Label ID="label" runat="server" /> <asp:TextBox ID="textbox" runat="server" />
    </ItemTemplate>
    <SeparatorTemplate>
        <br />
    </SeparatorTemplate>
</asp:Repeater>