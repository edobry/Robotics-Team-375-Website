<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DisplayPerson.ascx.cs" Inherits="Controls_DisplayPerson" %>

<h2><asp:Literal ID="litName" runat="server"></asp:Literal></h2>

<asp:Panel ID="Panel1" runat="server">
    <asp:PlaceHolder ID="phImg" runat="server" Visible="false">
        <div style="float:right;">
            <asp:image AlternateText="" ID="imgProfile" runat="server" />
        </div>
    </asp:PlaceHolder>
        
    <asp:Label ID="lblSubteam" Font-Bold="true" Text="Subteam:" runat="server" /> <asp:Literal ID="litSubteam" runat="server" />
    <asp:Label ID="lblHobbies" Font-Bold="true" Text="Hobbies and Interests:" runat="server" /> <asp:Literal ID="litHobbies" runat="server" />
    <br />
    
    <ASP:placeholder ID="phEdit" runat="server" Visible="false">
        <asp:HyperLink ID="HyperLink1" NavigateUrl="~/members/profile.aspx" runat="server">Edit Profile</asp:HyperLink>
    </ASP:placeholder>
    
</asp:Panel>
