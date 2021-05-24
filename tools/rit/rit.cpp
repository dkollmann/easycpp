#include <Windows.h>
#include <iostream>

int main()
{
	std::wstring cmd = GetCommandLine();
	size_t pos = cmd.find(L"--run");

	if (pos != std::wstring::npos)
	{
		std::wstring run = cmd.substr(pos + 6);

		STARTUPINFO si;
		ZeroMemory(&si, sizeof(si));
		si.cb = sizeof(si);

		PROCESS_INFORMATION pi;
		ZeroMemory(&pi, sizeof(pi));

		CreateProcess(NULL, (LPWSTR)run.c_str(), NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi);

		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	}
	else
	{
		std::cout << "Please use the following syntax to run this program:\nRunInTerminal.exe --run <executable> <args>" << std::endl;
	}
}
