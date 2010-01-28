<%@ Page Title="" Language="C#" MasterPageFile="~/simple.master" AutoEventWireup="true" CodeFile="approve.aspx.cs" Inherits="TeamRaile.Members_approve" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    Approve Requests
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">

            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
                CellPadding="3" GridLines="Vertical" style="margin-right: 3px" 
                DataSourceID="dsRequest" 
        onrowcreated="GridView1_RowCreated" BackColor="White" BorderColor="#999999" 
                BorderStyle="None" BorderWidth="1px">
                <AlternatingRowStyle BackColor="#DCDCDC" />
                <Columns>
                    <asp:TemplateField HeaderText="Request Type">
                        <ItemTemplate>
                            <asp:Label ID="RequestTypeLabel" runat="server" 
                                Text='<%# Eval("RequestType") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Requester">
                        <ItemTemplate>
                            <asp:Label ID="RequesterLabel" runat="server" Text='<%# Eval("Requester") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Request">
                        <ItemTemplate>
                            <asp:Label ID="RequestLabel" runat="server" Text='<%# Eval("Request") %>' Visible="false" />
                            
                            First Name: <asp:Literal ID="litFirst" runat="server"></asp:Literal>
                            <br />
                            Last Name: <asp:Literal ID="litLast" runat="server"></asp:Literal>
                            <br />
                            Telephone: <asp:Literal ID="litTelephone" runat="server"></asp:Literal>
                            <br />
                            Email: <asp:Literal ID="litEmail" runat="server"></asp:Literal>
                            <br />
                            Team Involvement: <asp:Literal ID="litCommittees" runat="server"></asp:Literal>
                            <br />
                            Career Goals: <asp:Literal ID="litCareer" runat="server"></asp:Literal>
                            <br />
                            Favorite Subject: <asp:Literal ID="litSubject" runat="server"></asp:Literal>
                            <br />
                            Grade Level (number): <asp:Literal ID="litGrade" runat="server"></asp:Literal>
                            <br />
                            Hobbies and Interests: <asp:Literal ID="litHobbies" runat="server"></asp:Literal>
                            <br />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approve/Deny">
                        <ItemTemplate>
                            <asp:Button ID="btnApprove" runat="server" CausesValidation="False" 
                                CommandName="Approve" oncommand="ApproveDeny" Text="Approve" UseSubmitBehavior="False" Width="80px" CommandArgument='<%# Eval("RequestID") %>' />
                            &nbsp;<asp:Button ID="btnDeny" runat="server" CausesValidation="False"
                                CommandName="Deny" oncommand="ApproveDeny" Text="Deny" UseSubmitBehavior="False" Width="80px" CommandArgument='<%# Eval("RequestID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <FooterStyle BackColor="#CCCCCC" ForeColor="Black" />
                <HeaderStyle BackColor="#000084" Font-Bold="True" ForeColor="White" />
                <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
                <RowStyle BackColor="#EEEEEE" ForeColor="Black" />
                <SelectedRowStyle BackColor="#008A8C" Font-Bold="True" ForeColor="White" />
            </asp:GridView>
    
    <br />
    
    <asp:AccessDataSource ID="dsRequest" runat="server" 
        ConflictDetection="CompareAllValues" DataFile="~/db.mdb"
        OldValuesParameterFormatString="original_{0}" 
        SelectCommand="SELECT * FROM [Requests]">
    </asp:AccessDataSource>
</asp:Content>

