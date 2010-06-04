<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pheading" Runat="Server">
    Login
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pmain" Runat="Server">
<div style="margin-left:50px;">
<asp:Login ID="Login1" runat="server" RememberMeSet="True" BackColor="#F7F6F3" 
        BorderColor="#E6E2D8" BorderPadding="4" BorderStyle="Solid" BorderWidth="1px" 
        Font-Names="Verdana" Font-Size="0.8em" ForeColor="#333333" >
    <InstructionTextStyle Font-Italic="True" ForeColor="Black" />
    <LoginButtonStyle BackColor="#FFFBFF" BorderColor="#CCCCCC" BorderStyle="Solid" 
        BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#284775" />
    <TextBoxStyle Font-Size="0.8em" />
    <TitleTextStyle BackColor="#5D7B9D" Font-Bold="True" Font-Size="0.9em" 
        ForeColor="White" />
    </asp:Login>
</div>
</asp:Content>