<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="photos.aspx.cs" Inherits="media_photos" %>
<%@ Register Src="photos/album.ashx" TagPrefix="photo" TagName="album" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
    <link href="album.css" rel="stylesheet" type="text/css" media="screen" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    Photos
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">
    <photo:album HandlerUrl="~/media/Photos/album.ashx" runat="server" ID="Album1" CssClass="album" />
</asp:Content>