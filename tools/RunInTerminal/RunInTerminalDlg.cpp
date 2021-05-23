
// RunInTerminalDlg.cpp : implementation file
//

#include "pch.h"
#include "framework.h"
#include "RunInTerminal.h"
#include "RunInTerminalDlg.h"
#include "afxdialogex.h"
#include "runprocess.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CRunInTerminalDlg dialog



CRunInTerminalDlg::CRunInTerminalDlg(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_RUNINTERMINAL_DIALOG, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CRunInTerminalDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CRunInTerminalDlg, CDialogEx)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_GETMINMAXINFO()
END_MESSAGE_MAP()


// CRunInTerminalDlg message handlers

BOOL CRunInTerminalDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	m_text.reserve(ProcessBufferSize * 10);
	m_text.push_back(0);  // always have the terminating zero

	m_textedit = static_cast<CEdit*>(GetDlgItem(IDC_EDIT1));

	CRect rect;
	GetWindowRect(&rect);

	m_minWidth = rect.Width();
	m_minHeight = rect.Height();

	std::wstring cmd = GetCommandLine();
	size_t pos = cmd.find(L"--run");

	if (pos != std::wstring::npos)
	{
		std::wstring run = cmd.substr(pos + 6);

		runprocess<wchar_t>::exec(run.c_str(), m_processBuffer, ProcessBufferSize, [](const wchar_t*, size_t, void* userdata) { static_cast<CRunInTerminalDlg*>(userdata)->OnRunProcessData(); }, this);
	}
	else
	{
		MessageBox(L"Please use the following syntax to run this program:\nRunInTerminal.exe --run <executable> <args>", L"Missing Argument");

		PostQuitMessage(1);
	}

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CRunInTerminalDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CRunInTerminalDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CRunInTerminalDlg::OnGetMinMaxInfo(MINMAXINFO* lpMMI)
{
	lpMMI->ptMinTrackSize.x = m_minWidth;
	lpMMI->ptMinTrackSize.y = m_minHeight;
}

void CRunInTerminalDlg::OnRunProcessData()
{
	ASSERT(m_text.size() > 0);

	size_t len = std::wcslen(m_processBuffer);
	size_t pos = m_text.size() - 1;

	m_text.resize(m_text.size() + len);

	std::memcpy(m_text.data() + pos, m_processBuffer, (len + 1) * sizeof(wchar_t));

	m_textedit->SetWindowText(m_text.data());
}
