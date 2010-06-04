<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="people.aspx.cs" Inherits="people" %>
<%@ Register TagPrefix="uc" TagName="DisplayPerson" Src="~/Controls/DisplayPerson.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    Team Members
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">

    <asp:Repeater ID="ProfileRepeater1" runat="server" 
        onitemdatabound="ProfileRepeater1_ItemDataBound">
        <ItemTemplate>
            <div style="overflow:hidden;">
                <uc:DisplayPerson runat="server" height="250" ID="DisplayPerson1" />
            </div>
        </ItemTemplate>
        <SeparatorTemplate>
            <hr />
        </SeparatorTemplate>
    </asp:Repeater>
    
</asp:Content>

