using System;
using System.Collections.Generic;
using SalarSoft.ASProxy;
using System.Net;
using System.Web.UI.WebControls;

public partial class Admin_Users : System.Web.UI.Page
{
	private const string _Str_AllowedList = "AllowedList";
	private const string _Str_AllowedRange = "AllowedRange";
	private const string _Str_BlockedList = "BlockedList";
	private const string _Str_BlockedRange = "BlockedRange";
	private const string _Str_RangeSeperate = " - ";
	private const string _Str_BlockedName = "Blocked: ";
	private const string _Str_AllowedName = "Allowed: ";


	List<string> _errorsList = new List<string>();

	void AddError(string errorMessage)
	{
		_errorsList.Add(errorMessage);
	}

	private void LoadFormData()
	{
		btnLoginEnable.Enabled = !Configurations.Authentication.Enabled;
		btnLoginDisable.Enabled = Configurations.Authentication.Enabled;
		chkLoginEnabled.Checked = Configurations.Authentication.Enabled;

		btnUACEnable.Enabled = !Configurations.UserAccessControl.Enabled;
		btnUACDisable.Enabled = Configurations.UserAccessControl.Enabled;
		chkUACEnabled.Checked = Configurations.UserAccessControl.Enabled;
	}

	void FillTheListBoxes()
	{
		lstUsersList.Items.Clear();
		if (Configurations.Authentication.Users != null)
		{
			foreach (Configurations.AuthenticationConfig.User user in Configurations.Authentication.Users)
			{
				lstUsersList.Items.Add(user.UserName);
			}
		}

		lstUACList.Items.Clear();
		// Nothing still
	}

	void FillUACListBox()
	{
		if (Configurations.UserAccessControl.AllowedList != null)
			foreach (string ip in Configurations.UserAccessControl.AllowedList)
			{
				lstUACList.Items.Add(new ListItem(_Str_AllowedName + ip, _Str_AllowedList));
			}
		if (Configurations.UserAccessControl.AllowedRange != null)
			foreach (Configurations.UserAccessControlConfig.IPRange range in Configurations.UserAccessControl.AllowedRange)
			{
				lstUACList.Items.Add(new ListItem(_Str_AllowedName + range.Low + _Str_RangeSeperate + range.High, _Str_AllowedRange));
			}

		if (Configurations.UserAccessControl.BlockedList != null)
			foreach (string ip in Configurations.UserAccessControl.BlockedList)
			{
				lstUACList.Items.Add(new ListItem(_Str_BlockedName + ip, _Str_BlockedList));
			}

		if (Configurations.UserAccessControl.BlockedRange != null)
			foreach (Configurations.UserAccessControlConfig.IPRange range in Configurations.UserAccessControl.BlockedRange)
			{
				lstUACList.Items.Add(new ListItem(_Str_BlockedName + range.Low + _Str_RangeSeperate + range.High, _Str_BlockedRange));
			}
	}

	void DisplayErrors(List<string> errorsList)
	{
		if (errorsList.Count == 0)
			return;
		ltErrorsList.Visible = true;
		strin