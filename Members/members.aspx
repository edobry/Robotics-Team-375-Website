<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="members.aspx.cs" Inherits="Members_members" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
Hello, <asp:Literal ID="litName" runat="server"></asp:Literal>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">
    <asp:HyperLink ID="linkProfile" runat="server">View Profile</asp:HyperLink> | <asp:HyperLink NavigateUrl="~/members/profile.aspx" runat="server">Edit Profile</asp:HyperLink>
    <br />
    <asp:HyperLink ID="linkPass" runat="server" NavigateUrl="~/Members/changepass.aspx">Change Password</asp:HyperLink>
    <br />
    <asp:LoginView ID="LoginView1" runat="server">
        <RoleGroups>
            <asp:RoleGroup Roles="Admin">
            <ContentTemplate>
                <asp:HyperLink NavigateUrl="~/admin/createuser.aspx" runat="server">Create User</asp:HyperLink>
            </ContentTemplate>
            </asp:RoleGroup>
        </RoleGroups>
    </asp:LoginView>
    <br />
</asp:Content>

