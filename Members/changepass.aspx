<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="changepass.aspx.cs" Inherits="Members_changepass" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
Change Password
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">

    <asp:ChangePassword ID="ChangePassword1" runat="server" ContinueDestinationPageUrl="~/Members/members.aspx">
    </asp:ChangePassword>

</asp:Content>

