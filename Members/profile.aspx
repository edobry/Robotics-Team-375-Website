<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="profile.aspx.cs" Inherits="profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    Profile
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">
    
    <asp:PlaceHolder ID="phConfirm" Visible="false" runat="server">
        <div style="background-color:Silver;border:3px solid black;max-width:300px;margin:10px;padding:5px;">
            <span style="font-weight:bold">Your profile change has been submitted</span>
            <br/>
            <asp:HyperLink ID="hlProfile" NavigateUrl="~/person.aspx" Text="View Profile" runat="server" />
        </div>
    </asp:PlaceHolder>
       
    <asp:Panel ID="Panel1" runat="server" DefaultButton="updateProfileButton">
        First Name:
        <asp:TextBox runat="server" ID="First" AutoCompleteType="FirstName" 
              />
        <br />
        Last Name:
        <asp:TextBox runat="server" ID="Last" AutoCompleteType="LastName"  />
        <br />
        Email:
        <asp:TextBox runat="server" ID="Email" AutoCompleteType="Email"  />
        <br />
        Grade Level (number):
        <asp:TextBox runat="server" ID="Grade" AutoCompleteType="Disabled"  />
        <br />
        Subteam:
        <asp:CheckBoxList ID="cblSubteams" RepeatDirection="Horizontal" RepeatColumns="3" runat="server" style="display:inline-table;vertical-align:middle;margin:10px;"></asp:CheckBoxList>
        <br />
        Hobbies and Interests:
        <asp:TextBox runat="server" ID="Hobbies" AutoCompleteType="Disabled"  />
        <br />
        Change photo:
        <asp:FileUpload ID="FileUpload1" runat="server" />
        <br /><br />
        
        <asp:Button runat="server" ID="updateProfileButton"
              Text="Save Preferences" onclick="updateProfile" />
    </asp:Panel>
</asp:Content>