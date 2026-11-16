# pragma once
# include <Siv3D.hpp>

//
// ライセンス一覧の表示 (LicenseManager::EnumLicenses() の内容)。
//
// Siv3D のアプリは、組み込んだライブラリのライセンス文を利用者が見られるようにする必要がある。
// Windows / macOS / Linux / Web では LicenseManager::ShowInBrowser() (既定では F1 キー) でブラウザに表示できるが、
// Android / iOS ではアプリ内の HTML を他のアプリに渡せないので、アプリの画面に表示する (このクラス)。
// 詳しくは OpenSiv3D の SDL3/LICENSES.md を参照。
//
// 使い方:
//   LicenseView licenseView;
//   while (System::Update())
//   {
//       if (licenseView.isOpen()) { licenseView.update(); continue; }   // 表示中は一覧だけを描く
//       ...
//       if (SimpleGUI::Button(U"Licenses", ...)) { licenseView.open(); }
//   }
//

class LicenseView
{
public:

	/// @brief アプリ内に表示するか (false ならブラウザで開く)
	[[nodiscard]]
	static constexpr bool UseInAppView() noexcept
	{
	# if SIV3D_PLATFORM(IOS) || defined(__ANDROID__)
		return true;
	# else
		return false;
	# endif
	}

	/// @brief ライセンス一覧を開きます。
	/// @param inApp アプリ内に表示する場合 true (既定は機種に合わせる)
	void open(const bool inApp = UseInAppView())
	{
		if (not inApp)
		{
			LicenseManager::ShowInBrowser();
			return;
		}

		m_open = true;
		m_scroll = 0.0;
		m_layoutWidth = 0.0; // 次の update で組み直す
	}

	void close() noexcept
	{
		m_open = false;
	}

	[[nodiscard]]
	bool isOpen() const noexcept
	{
		return m_open;
	}

	/// @brief 表示中なら、入力の処理と描画をします (シーン全体を覆う)。
	void update()
	{
		if (not m_open)
		{
			return;
		}

		const RectF area{ Margin, (Margin + HeaderHeight), (Scene::Width() - Margin * 2), (Scene::Height() - Margin * 2 - HeaderHeight) };

		// シーンの幅に合わせて行を組み直す (初回と、ウィンドウの大きさが変わったとき)
		if (m_layoutWidth != area.w)
		{
			layout(area.w - Padding * 2);
			m_layoutWidth = area.w;
		}

		// スクロール: マウスホイールと、ドラッグ (タッチもマウスとして届く)
		const double contentHeight = (m_lines.size() * LineHeight + Padding * 2);
		const double maxScroll = Max(0.0, contentHeight - area.h);

		m_scroll += (Mouse::Wheel() * LineHeight * 3);

		// 右端 (スクロールバーの帯) をドラッグすると、その位置へ直接移動する (長い一覧を素早く送るため)
		const RectF scrollStrip{ (area.rightX() - ScrollStripWidth), area.y, ScrollStripWidth, area.h };

		if (MouseL.down() && area.mouseOver())
		{
			m_dragging = true;
			m_draggingBar = scrollStrip.mouseOver();
		}
		else if (MouseL.up())
		{
			m_dragging = false;
			m_draggingBar = false;
		}

		if (m_draggingBar)
		{
			m_scroll = (Clamp((Cursor::PosF().y - area.y) / area.h, 0.0, 1.0) * maxScroll);
		}
		else if (m_dragging)
		{
			m_scroll -= Cursor::DeltaF().y;
		}

		m_scroll = Clamp(m_scroll, 0.0, maxScroll);

		// 描画
		Scene::Rect().draw(ColorF{ 0.0, 0.75 });
		RectF{ Margin, Margin, area.w, (HeaderHeight + area.h) }.draw(ColorF{ 0.97 });
		m_titleFont(U"Licenses").draw(TitleSize, Arg::leftCenter((Margin + Padding), (Margin + HeaderHeight / 2)), ColorF{ 0.1 });

		if (SimpleGUI::Button(U"Close", Vec2{ (Margin + area.w - 110), (Margin + 8) }, 100))
		{
			close();
			return;
		}

		{
			const ScopedViewport2D viewport{ area.asRect() };
			const size_t first = static_cast<size_t>(Max(0.0, (m_scroll - Padding) / LineHeight));
			const size_t last = Min(m_lines.size(), (first + static_cast<size_t>(area.h / LineHeight) + 2));

			for (size_t i = first; i < last; ++i)
			{
				const Line& line = m_lines[i];
				const double y = (Padding + i * LineHeight - m_scroll);
				const double size = (line.kind == Kind::Title) ? HeadingSize : TextSize;
				const ColorF color = (line.kind == Kind::Title) ? ColorF{ 0.05 } : (line.kind == Kind::Copyright) ? ColorF{ 0.25 } : ColorF{ 0.35 };
				m_font(line.text).draw(size, Padding, y, color);
			}
		}

		// スクロールバー
		if (0.0 < maxScroll)
		{
			const double barHeight = Max(24.0, area.h * (area.h / contentHeight));
			const double barY = (area.y + (area.h - barHeight) * (m_scroll / maxScroll));
			RectF{ (area.rightX() - 6), barY, 4, barHeight }.rounded(2).draw(ColorF{ 0.6 });
		}
	}

private:

	enum class Kind { Title, Copyright, Text, Blank };

	struct Line
	{
		String text;
		Kind kind = Kind::Text;
	};

	static constexpr double Margin = 12;
	static constexpr double HeaderHeight = 52;
	static constexpr double Padding = 16;
	static constexpr double TitleSize = 26;
	static constexpr double HeadingSize = 20;
	static constexpr double TextSize = 14;
	static constexpr double LineHeight = 22;
	static constexpr double ScrollStripWidth = 40;

	Font m_font{ FontMethod::MSDF, 24 };

	Font m_titleFont{ FontMethod::MSDF, 32, Typeface::Bold };

	Array<Line> m_lines;

	HashTable<char32, double> m_advanceCache;

	double m_layoutWidth = 0.0;

	double m_scroll = 0.0;

	bool m_open = false;

	bool m_dragging = false;

	bool m_draggingBar = false;

	[[nodiscard]]
	double advance(const char32 ch, const double size)
	{
		auto it = m_advanceCache.find(ch);

		if (it == m_advanceCache.end())
		{
			it = m_advanceCache.emplace(ch, m_font.getGlyphInfo(ch).xAdvance).first;
		}

		return (it->second * size / m_font.fontSize());
	}

	// 1 段落を幅 width で折り返して lines に足す (空白で区切れるところで折り返し、無ければ文字の途中で)
	void wrap(const String& paragraph, const double width, const double size, const Kind kind)
	{
		if (paragraph.isEmpty())
		{
			m_lines << Line{ U"", Kind::Blank };
			return;
		}

		size_t lineStart = 0;
		size_t lastSpace = String::npos;
		double x = 0.0;

		for (size_t i = 0; i < paragraph.size(); ++i)
		{
			const char32 ch = paragraph[i];

			if (ch == U' ')
			{
				lastSpace = i;
			}

			x += advance(ch, size);

			if ((width < x) && (lineStart < i))
			{
				const size_t breakAt = ((lastSpace != String::npos) && (lineStart < lastSpace)) ? lastSpace : i;
				m_lines << Line{ paragraph.substr(lineStart, (breakAt - lineStart)), kind };
				lineStart = ((breakAt == lastSpace) ? (breakAt + 1) : breakAt);
				lastSpace = String::npos;
				i = (lineStart - 1);
				x = 0.0;
			}
		}

		if (lineStart < paragraph.size())
		{
			m_lines << Line{ paragraph.substr(lineStart), kind };
		}
	}

	void layout(const double width)
	{
		m_lines.clear();

		for (const auto& license : LicenseManager::EnumLicenses())
		{
			if (license.title.isEmpty())
			{
				continue;
			}

			wrap(license.title, width, HeadingSize, Kind::Title);
			m_lines << Line{ U"", Kind::Blank }; // 見出しは本文より大きいので 1 行空ける

			for (const auto& paragraph : license.copyright.split_lines())
			{
				wrap(paragraph, width, TextSize, Kind::Copyright);
			}

			m_lines << Line{ U"", Kind::Blank };

			for (const auto& paragraph : license.text.split_lines())
			{
				wrap(paragraph, width, TextSize, Kind::Text);
			}

			m_lines << Line{ U"", Kind::Blank };
			m_lines << Line{ U"", Kind::Blank };
		}
	}
};
