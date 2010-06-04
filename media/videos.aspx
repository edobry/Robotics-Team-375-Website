<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="videos.aspx.cs" Inherits="media_videos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    Videos
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">
<h2>Nationals 2005</h2>
    <h4>Curie Qualifying Match</h4>
    <div>
        <asp:HyperLink ID="imgny2005" NavigateUrl="~/media/videos/ny2005.wmv" ImageUrl="~/media/videos/ny2005.jpg" CssClass="imgVideo" Text="Download" runat="server" />
        One of the 2005 division qualifying matches. Rocky and his team members take the competition by storm in this Tic-Tac-Toe style - tetrahedron stacking competition.<br />
        <asp:HyperLink ID="hlny2005dl" NavigateUrl="~/media/videos/ny2005.wmv" CssClass="dlLink" Text="Download" runat="server" />
    </div>
    
<h2>New York City Reigonal 2006</h2>
    <h4>Autonomous Mode: One of Rambo's 32 Autonoumous Modes</h4>
    <div>
        <asp:HyperLink ID="imgny2006" NavigateUrl="~/media/videos/ny2006.wmv" ImageUrl="~/media/videos/ny2006.jpg" CssClass="imgVideo" Text="Download" runat="server" />
        With a scoring record like this, it's a surprise the robot wasn't nominated for a basketball MVP.<br />
        <asp:HyperLink ID="hlny2006dl" NavigateUrl="~/media/videos/ny2006.wmv" CssClass="dlLink" Text="Download" runat="server" />
    </div>

<h2>New Jersey Reigonal 2006</h2>
    <h4>Qualifying Round</h4>
    <div>
        <asp:HyperLink ID="imgnj2006_1" NavigateUrl="~/media/videos/nj2006-1.wmv" ImageUrl="~/media/videos/nj2006-1.jpg" CssClass="imgVideo" Text="Download" runat="server" />
        One of Rambo's 8 undefeated qualifying matches in the New Jersey Competition.<br />
        <asp:HyperLink ID="hlnj2006_1dl" NavigateUrl="~/media/videos/nj2006-1.wmv" CssClass="dlLink" Text="Download" runat="server" />
    </div>
    
    <h4>Elimination Round</h4>
    <div>
        <asp:HyperLink ID="imgnj2006_2" NavigateUrl="~/media/videos/nj2006-2.wmv" ImageUrl="~/media/videos/nj2006-2.jpg" CssClass="imgVideo" Text="Download" runat="server" />
        A new jersery elimination match played by Rambo and the alliance he led all the way to the Finals of the tournament.<br />
        <asp:HyperLink ID="hlnj2006_2dl" NavigateUrl="~/media/videos/nj2006-2.wmv" CssClass="dlLink" Text="Download" runat="server" />
    </div>
</asp:Content>

