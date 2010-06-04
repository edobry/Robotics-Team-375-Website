<%@ Page Title="Manage stored cookies by ASProxy in your PC" Inherits="SalarSoft.ASProxy.PageInMasterLocale" Language="C#" MasterPageFile="~/Theme.master" culture="auto" meta:resourcekey="Page" uiculture="auto" %>
<%@ Import Namespace="SalarSoft.ASProxy" %>
<script runat="server">
	const string authenticationCookie = "ASProxyUser";
	const string sessionStateCookie = "ASProxySession";

	private HttpCookieCollection GetCookiesCollection()
	{
		HttpCookieCollection result = new HttpCookieCollection();
		for (int i = 0; i < Request.Cookies.Count; i++)
		{
			HttpCookie cookie = Request.Cookies[i];
			if (cookie.Name != sessionStateCookie &&
				cookie.Name != authenticationCookie &&
				cookie.Name != Consts.FrontEndPresentation.UserOptionsCookieName &&
				cookie.Name != Consts.FrontEndPresentation.HttpCompressor)
			{
				result.Add(cookie);
			}
		}
		return result;
	}

	protected void Page_Load(object sender, EventArgs e)
	{
		rptCookies.DataSource = GetCookiesCollection();

		rptCookies.DataBind();
	}

	protected void rptCookies_btnDelete(object source, EventArgs e)
	{
		Button btn = (Button)source;
		string cookieName = btn.CommandArgument;

		if (btn.CommandName == "DeleteCookie")
		{
			HttpCookie cookie = Response.Cookies[cookieName];
			cookie.Expires = DateTime.Now.AddYears(-10);

			Response.Cookies.Add(cookie);
			Response.Redirect(Request.Url.ToString(), false);
		}
	}

	protected void rptCookies_btnClearCookies(object source, EventArgs e)
	{
		Button btn = (Button)source;
		string cmdName = btn.CommandName;

		if (cmdName == "ClearCookies")
		{
			HttpCookieCollection reqCookies = GetCookiesCollection();
			for (int i = 0; i < reqCookies.Count; i++)
			{
				HttpCookie cookie = reqCookies[i];
				cookie.Expires = DateTime.Now.AddYears(-10);
				Response.Cookies.Add(cookie);
			}
			Response.Redirect(Request.Url.ToString(), false);
		}
	}
</script>

<asp:Content ContentPlaceHolderID="plhHeadMeta" Runat="Server">
<title>Manage stored cookies by ASProxy in your PC</title>
	<style type="text/css">
		.desc
		{
			overflow: auto;
		}
		.cookieValue
		{
			min-height: 25px;
			max-height: 90px;
			overflow-y: auto;
			width: 650px;
			word-break: break-all;
			word-wrap: break-word;
		}
		.tblOptions
		{
			margin-top: 10px;
		}
		.option th
		{
			background-color: black;
			color: White;
			margin: 0 auto;
			padding: 10px 0 10px 0;
			text-align: center;
			-moz-border-radius: 10px 10px 0px 0px;
			-webkit-border-radius: 10px 10px 0px 0px;
			border-radius: 10px 10px 0px 0px;
		}
	</style>
</asp:Content>


<asp:Content ContentPlaceHolderID="plhMainBar" Runat="Server">
<script type="text/javascript">	doc