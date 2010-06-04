using System;
using System.Web.Security;
using System.Web.Profile;
using System.Linq;
using System.Collections.Generic;

/// <summary>
/// Summary description for main
/// </summary>
public class main
{
	public main()
	{
		//
		// TODO: Add constructor logic here
		//
	}
}

public class Subteams
{
    /// <summary>
    /// List of possible subteams.
    /// </summary>
    public enum SubteamsEnum
    {
        Animation,
        Build,
        Chairmans,
        Programming,
        Website
    }

    /// <summary>
    /// Array of possible subteams.
    /// </summary>
    public static string[] SubteamsArray
    {
        get { return Enum.GetNames(typeof(SubteamsEnum)); }
    }

    /// <summary>
    /// Returns array of subteams given input string.
    /// </summary>
    public static string[] ToArray(string input)
    {
        string[] seperator = new string[1];
        seperator[0] = ", ";
        return input.Split(seperator, StringSplitOptions.RemoveEmptyEntries);
    }

    /// <summary>
    /// Returns string given array of subteams.
    /// </summary>
    public static string FromArray(string[] input)
    {
       return String.Join(", ", input);
    }

    /// <summary>
    /// Returns string given array of indexes.
    /// </summary>
    public static string SetSubteams(int[] selected)
    {
        string selSubteams = "";
        int i = 1;
        foreach (int index in selected)
        {
            selSubteams += i < selected.Count() ? Enum.GetName(typeof(SubteamsEnum), index) + ", " : Enum.GetName(typeof(SubteamsEnum), index);
            i++;
        }
        return selSubteams;
    }

    /// <summary>
    /// Gets all users in a subteam.
    /// </summary>
    public static List<String> GetUsersInSubteam(SubteamsEnum subteam)
    {
        List<String> users = new List<string>();
        foreach(MembershipUser user in Membership.GetAllUsers())
        {
            if(GetUsersSubteams((ProfileCommon)ProfileCommon.Create(user.UserName)).Contains(subteam.ToString())) users.Add(user.UserName);
        }
        return users;
    }

    /// <summary>
    /// Gets all users in a subteam.
    /// </summary>
    public static List<String> GetUsersInSubteam(string subteam)
    {
        List<String> users = new List<string>();
        foreach (MembershipUser user in Membership.GetAllUsers())
        {
            if (GetUsersSubteams((ProfileCommon)ProfileCommon.Create(user.UserName)).Contains(subteam)) users.Add(user.UserName);
        }
        return users;
    }
    /// <summary>
    /// Gets subteams user is in.
    /// </summary>
    public static List<String> GetUsersSubteams(string user)
    {
        List<String> subteams = new List<string>();
        ProfileCommon userProfile = (ProfileCommon)ProfileCommon.Create(user);
        subteams.AddRange(Subteams.ToArray(userProfile.GetPropertyValue("Subteam").ToString()));
        return subteams;
    }

    /// <summary>
    /// Gets subteams user is in.
    /// </summary>
    public static List<String> GetUsersSubteams(ProfileCommon user)
    {
        List<String> subteams = new List<string>();
        subteams.AddRange(Subteams.ToArray(user.GetPropertyValue("Subteam").ToString()));
        return subteams;
    }
}