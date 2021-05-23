
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
	int m_minWidth = 0;
	int m_minHeight = 0;

	const static size_t ProcessBufferSize = 256;

	wchar_t m_processBuffer[ProcessBufferSize] = { 0 };

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()

	void OnRunProcessData();

public:
//	afx_msg void OnEnChangeEdit1();
//	afx_msg void OnEnChangeEdit1();
	afx_msg void OnGetMinMaxInfo(MINMAXINFO* lpMMI);
};
