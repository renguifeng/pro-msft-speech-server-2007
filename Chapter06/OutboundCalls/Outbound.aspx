<!-- Note: This file cannot be displayed correctly via "View in Browser" option in Visual Studio. -->
<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.Security" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.Web.UI.WebControls.WebParts" %>
<%@ Import Namespace="System.Web.UI.HtmlControls" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Security" %>

<script language="C#" runat="server">

    private string outboundPhoneNumberQueryString = String.Empty;
    private string paramQueryString = String.Empty;

    protected void TriggerButton_Click(object sender, EventArgs e)
    {
        UpdateDisplayedFullURI();

        this.ErrorMessageLabel.Text = String.Empty;

        String outboundUri = this.DisplayedFullURILabel.Text;

        // Initiate the outbound calling via web request
        HttpWebRequest request = null;

        // Initiate the outbound calling via web request
        try
        {
            request = (HttpWebRequest)WebRequest.Create(outboundUri);
        }
        catch (NotSupportedException)
        {
            this.ErrorMessageLabel.Text =
			   "The request scheme specified in <b>Full URI</b> has not been registered.";
        }
        catch (ArgumentNullException)
        {
            this.ErrorMessageLabel.Text =
			   "The URI specified in <b>Full URI</b> is a null reference.";
        }
        catch (SecurityException)
        {
            this.ErrorMessageLabel.Text =
			   "The caller does not have permission to connect to the requested URI or a URI that the request is redirected to.";
        }
        catch (UriFormatException)
        {
            this.ErrorMessageLabel.Text =
			   "The URI specified in <b>Full URI</b> is not a valid URI.";
        }

        if (request != null)
        {
            // Set the credentials.
            request.Credentials = CredentialCache.DefaultCredentials;
            request.ContentLength = 0;
            request.Method = "POST";
            request.Timeout = 30000;

            try
            {
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            }
            catch (ProtocolViolationException)
            {
                this.ErrorMessageLabel.Text =
					"Protocol Violation: KeepAlive is true, AllowWriteStreamBuffering is false, ContentLength is -1, and SendChunked is false.";
            }
            catch (WebException exn)
            {
                if (null != exn.Response && exn.Status == WebExceptionStatus.ProtocolError)
                {
                    if (((HttpWebResponse)exn.Response).StatusCode == HttpStatusCode.NotFound)
                    {
                        this.ErrorMessageLabel.Text =
							"The requested application was not found. Please make sure that the URL specified in the Outbound Application URL textbox is correct.";
                    }
                    else if (((HttpWebResponse)exn.Response).StatusCode == HttpStatusCode.Forbidden)
                    {
                        this.ErrorMessageLabel.Text =
							"The request was forbidden. Please make sure the application is running and Speech Debugging Window is visible.";
                    }
                    else if (((HttpWebResponse)exn.Response).StatusCode == HttpStatusCode.RequestTimeout)
                    {
                        this.ErrorMessageLabel.Text =
							"The request has timed-out. Please try again.";
                    }
                }
                else
                {
                    this.ErrorMessageLabel.Text = exn.Message;
                }
            }
            catch (InvalidOperationException)
            {
                this.ErrorMessageLabel.Text =
				   "Either the response stream is already in use by a previous call to BeginGetResponse, or TransferEncoding is set to a value and SendChunked is false.";
            }
            catch (NotSupportedException)
            {
                this.ErrorMessageLabel.Text =
				   "The request cache validator indicated that the response for this request can be served from the cache; however, this request includes data to be sent to the server. Requests that send data must not use the cache. This exception can occur if you are using a custom cache validator that is incorrectly implemented.";
            }

            // If there was no error, indicate success
            if (this.ErrorMessageLabel.Text.Equals(String.Empty))
            {
                this.ErrorMessageLabel.Text = "Trigger sent successfully";
            }
        }
    }

    protected void AddParamButton_Click(object sender, EventArgs e)
    {
        string param = this.ParamTextBox.Text;
        string value = this.ValueTextBox.Text;
        string escapedString = Uri.EscapeUriString(param + "=" + value);

        this.ParamListBox.Items.Add(new ListItem(escapedString));
        UpdateDisplayedFullURI();
    }

    protected void RemoveParamButton_Click(object sender, EventArgs e)
    {
        this.ParamListBox.Items.Remove(this.ParamListBox.SelectedItem);
        UpdateDisplayedFullURI();
    }

    protected void PhoneNumTextBox_TextChanged(object sender, EventArgs e)
    {
        UpdateDisplayedFullURI();
    }

    private void UpdateDisplayedFullURI()
    {
        this.paramQueryString = String.Empty;
        foreach (ListItem item in this.ParamListBox.Items)
        {
            this.paramQueryString += "&" + item.Value;
        }
        if (this.PhoneNumTextBox.Text.Length > 0)
        {
            this.outboundPhoneNumberQueryString = "OutboundPhoneNumber=" + this.PhoneNumTextBox.Text;
        }
        else
        {
            if (this.paramQueryString.Length > 0)
            {
                // Remove the first "&" from the param query string
                this.paramQueryString = this.paramQueryString.Remove(0, 1);
            }
            this.outboundPhoneNumberQueryString = String.Empty;
        }
        if (this.outboundPhoneNumberQueryString.Length > 0 || this.paramQueryString.Length > 0)
        {
            this.DisplayedFullURILabel.Text = this.OutboundApp.Text + "?" + this.outboundPhoneNumberQueryString + this.paramQueryString;
        }
        else
        {
            this.DisplayedFullURILabel.Text = this.OutboundApp.Text;
        }
    }

    protected void OutboundApp_TextChanged(object sender, EventArgs e)
    {
        UpdateDisplayedFullURI();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Sample Outbound Application Trigger Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div title="Sample Outbound Application Trigger">
        <br />
        <asp:Label ID="PageTitleLabel" runat="server" Font-Bold="True" Font-Names="Times New Roman"
            Font-Size="Larger" Height="36px" Text="Sample Outbound Application Trigger Page" Width="173px"></asp:Label><br />
        <br />
        <asp:Label ID="DescriptionLabel" runat="server" Text="This page is intended to be used to help Debug outbound calling applications. The http request sent by the Trigger causes the Outbound application to be run and make its call. When in Debug mode the Debugger will answer the call regardless of the intended destination defined by the application."></asp:Label><br />
        <br />
        <asp:Label ID="URLLabel" runat="server" Font-Bold="True" Text="Outbound Application URL:"></asp:Label><br />
        <asp:TextBox ID="OutboundApp" runat="server" Width="509px" OnTextChanged="OutboundApp_TextChanged">http://localhost/OutboundCalls/OutboundCalls.speax</asp:TextBox>
        <br />
        <asp:Label ID="PhoneNumLabel" runat="server" Font-Bold="True" Text="Phone Number:"></asp:Label>
        <asp:TextBox ID="PhoneNumTextBox" runat="server" Width="125px" OnTextChanged="PhoneNumTextBox_TextChanged">5555555</asp:TextBox><br />
        <br />
        <br />
        <br />
        <asp:Label ID="ParamLabel" runat="server" Font-Bold="True" Text="Param Name:"></asp:Label>
        <asp:TextBox ID="ParamTextBox" runat="server"></asp:TextBox>
        <asp:Label ID="ValueLabel" runat="server" Font-Bold="True" Text="Value:"></asp:Label>
        <asp:TextBox ID="ValueTextBox" runat="server"></asp:TextBox>&nbsp;&nbsp;<asp:Button ID="AddParamButton" runat="server" Height="24px" OnClick="AddParamButton_Click"
            Text="Add" Width="69px" /><br />
        <br />
        <asp:ListBox ID="ParamListBox" runat="server" Width="454px">
        </asp:ListBox>
        &nbsp;&nbsp;<asp:Button ID="RemoveParamButton" runat="server" OnClick="RemoveParamButton_Click"
            Text="Remove" /><br />
        <br />
        <br />
        <asp:Label ID="FullURILabel" runat="server" Height="26px" Width="697px" Font-Bold="True">Full URI:</asp:Label><asp:Label
            ID="DisplayedFullURILabel" runat="server">http://localhost/OutboundCalls/OutboundCalls.speax</asp:Label>
        <br />
        <asp:Button ID="TriggerButton" runat="server" OnClick="TriggerButton_Click" Text="Send Trigger" /><br />
        <br />
        <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Trigger Result:"></asp:Label>
        &nbsp;&nbsp;<br />
        <asp:Label ID="ErrorMessageLabel" runat="server"></asp:Label></div>

    </form>
</body>
</html>
