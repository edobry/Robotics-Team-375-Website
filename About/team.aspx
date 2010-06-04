<%@ Page Title="" Language="C#" MasterPageFile="~/layout.master" AutoEventWireup="true" CodeFile="team.aspx.cs" Inherits="team" %>
<%@ Register TagPrefix="uc" TagName="DisplayPerson" Src="~/Controls/DisplayPerson.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phead" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pheading" Runat="Server">
    <asp:Literal ID="litTeam" runat="server" />Team<asp:PlaceHolder ID="phReturn" runat="server" Visible="false"> - <a href="team.aspx" style="font-size:14px;text-decoration:none;vertical-align:middle;">Return to all teams</a></asp:PlaceHolder>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pmain" Runat="Server">

<asp:Panel ID="pnlTeams" runat="server" Visible="true">
    <p>
       Within our collective team are quite a few subteams. These include the build, animation, website, programming, and Chairman's team.
    </p>

    <asp:Repeater ID="rptTeam" DataSourceID="dsTeams" runat="server">
        <ItemTemplate>
            <div id='<%# ((System.Data.DataRowView)Container.DataItem)["TeamName"]%>t' class="teams">
                <h2><a href="team.aspx?name=<%# ((System.Data.DataRowView)Container.DataItem)["TeamName"]%>"><%# ((System.Data.DataRowView)Container.DataItem)["TeamName"]%> Team</a></h2>
                <p>
                    <%# ((System.Data.DataRowView)Container.DataItem)["ShortDesc"]%>
                </p>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<asp:Panel ID="pnlTeam" runat="server" Visible="false">
    <p>
        <asp:Literal ID="litDescription" runat="server" />
    </p>
    
    <asp:Repeater ID="TeamMembersRepeater1" runat="server" onitemdatabound="TeamMembersRepeater1_ItemDataBound">
        <ItemTemplate>
            <div style="overflow:hidden;">
                <uc:DisplayPerson runat="server" height="250" ID="DisplayPerson1" />
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<asp:AccessDataSource ID="dsTeams" runat="server" DataFile="~/App_Data/db.mdb" DataSourceMode="DataSet" SelectCommand="SELECT * FROM [Teams]"  />

</asp:Content>

