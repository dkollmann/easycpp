
// RunInTerminalDlg.h : header file
//

#pragma once


// CRunInTerminalDlg dialog
class CRunInTerminalDlg : public CDialogEx
{
// Construction
public:
	CRunInTerminalDlg(CWnd* pParent = nullptr);	// standard constructor

// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_RUNINTERMINAL_DIALOG };
#endif

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
//	afx_msg void OnEnChangeEdit1();
//	afx_msg void OnEnChangeEdit1();
};
