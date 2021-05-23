#pragma once

#include <vector>
#include <thread>
#include <mutex>
#include <array>
#include <assert.h>
#include "runprocess.h"

template<typename T> class runprocess_threaded
{
protected:

	std::vector<T> _command;
	std::thread _thread;
	std::vector<T> _text;
	std::mutex _textMutex;

	static size_t length(const char* str) { return std::strlen(str); }
	static size_t length(const wchar_t* str) { return std::wcslen(str); }

	void addtext(const T *buffer, size_t size)
	{
		assert(_text.size() > 0);

		const size_t len = length(buffer);

		_textMutex.lock();

		const size_t pos = _text.size() - 1;

		_text.resize(_text.size() + len);

		std::memcpy(_text.data() + pos, buffer, (len + 1) * sizeof(T));

		_textMutex.unlock();
	}

	static void run(runprocess_threaded<T> *self)
	{
		std::array<T, 128> buffer;

		runprocess<T>::exec(self->_command.data(), buffer.data(), buffer.size(), [](const T *buf, size_t size, void* userdata) { static_cast<runprocess_threaded<T>*>(userdata)->addtext(buf, size); }, self);
	}

public:

	runprocess_threaded()
	{
		_text.reserve(1024);
		_text.push_back(0);  // add null terminator
	}

	~runprocess_threaded()
	{
		_thread.join();
	}

	void exec(const T *cmd)
	{
		// the string needs to stay valid for the thread to run
		size_t len = length(cmd);
		_command.resize(len + 1);
		std::memcpy(_command.data(), cmd, (len + 1) * sizeof(T));

		_thread = std::thread(runprocess_threaded::run, this);
	}

	void read(std::string& text)
	{
		_textMutex.lock();

		text = _text.data();

		_text.resize(1);
		_text[0] = 0;

		_textMutex.unlock();
	}

	void read(std::wstring& text)
	{
		_textMutex.lock();

		text = _text.data();

		_text.resize(1);
		_text[0] = 0;

		_textMutex.unlock();
	}

	void read(std::vector<T>& text)
	{
		assert(text.size() > 0);

		_textMutex.lock();

		assert(_text.size() > 0);

		const size_t len = _text.size() - 1;

		if (len > 0)
		{
			const size_t pos = text.size() - 1;

			text.resize(text.size() + len);

			std::memcpy(text.data() + pos, _text.data(), (len + 1) * sizeof(T));

			_text.resize(1);
			_text[0] = 0;
		}
		
		_textMutex.unlock();
	}
};
