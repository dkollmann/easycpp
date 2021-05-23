#pragma once

#include <iostream>
#include <stdexcept>
#include <stdio.h>

template<typename T> class runprocess
{
private:

    template<typename TT> static FILE* open(const TT* command);
    template<typename TT> static TT* read(TT* str, int numchars, FILE *stream);

    template<> static char* read(char* str, int numchars, FILE* stream) { return fgets(str, numchars, stream); }

#ifdef _WIN32
    template<> static FILE* open(const char* command) { return _popen(command, "r"); }
    template<> static FILE* open(const wchar_t* command) { return _wpopen(command, L"r"); }

    template<> static wchar_t* read(wchar_t* str, int numchars, FILE* stream) { return fgetws(str, numchars, stream); }

    static int close(FILE* stream) { return _pclose(stream); }
#else
    template<> static FILE* open(const char* command) { return popen(command, "r"); }

    static int close(FILE* stream) { return pclose(stream); }
#endif

public:

    typedef void callback(const T *buffer, size_t buffer_size, void *userdata);

    static bool exec(const T *cmd, T *buffer, size_t buffer_size, callback *callbck, void *userdata = NULL)
    {
        FILE *pipe = open(cmd);

        if (!pipe)
            return false;

        try
        {
            while(read(buffer, buffer_size, pipe) != NULL)
            {
                callbck(buffer, buffer_size, userdata);
            }
        }
        catch(...)
        {
            close(pipe);
            return false;
        }

        close(pipe);
        return true;
    }
};
