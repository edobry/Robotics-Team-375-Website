<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="person.aspx.cs" Inherits="person" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    <asp:Literal ID="litName" runat="server"></asp:Literal>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">
    
    <asp:PlaceHolder ID="phImg" runat="server" Visible="false">
        <div style="float:right;">
            <asp:image AlternateText="" ID="imgProfile" runat="server" Width="200px" />
        </div>
    </asp:PlaceHolder>
    
    <asp:Panel ID="Panel1" runat="server">
    
        <asp:Label ID="lblSubteam" Font-Bold="true" Text="Subteam:" runat="server" /> <asp:Literal ID="litSubteam" runat="server" />
        <asp:Label ID="lblHobbies" Font-Bold="true" Text="Hobbies and Interests:" runat="server" /> <asp:Literal ID="litHobbies" runat="server" />
        <br />
        <ASP:placeholder ID="phEdit" runat="server" Visible="false">
            <asp:HyperLink ID="HyperLink1" NavigateUrl="~/members/profile.aspx" runat="server">Edit Profile</asp:HyperLink>
        </ASP:placeholder>
    </asp:Panel>
    
</asp:Content>

