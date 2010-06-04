<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="media.aspx.cs" Inherits="media" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    Media
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">
    <asp:HyperLink NavigateUrl="~/media/photos.aspx" Text="View photos from past years" runat="server" /><br />
    <asp:HyperLink NavigateUrl="~/media/videos.aspx" Text="Watch videos of our matches" runat="server" /><br />
    <asp:HyperLink NavigateUrl="~/media/animations.aspx" Text="Watch animations made by our Animation Team" runat="server" />
</asp:Content>

