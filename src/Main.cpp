# include <Siv3D.hpp>
# include "LicenseView.hpp"

void Main()
{
	// アセットはカレントディレクトリ (実行ファイルのフォルダ) からの相対パスで読む
	// (siv3d-app.json の "assets" で assets/ を実行ファイルの隣にコピーしている)
	const Texture texture{ U"assets/windmill.png" };
	const Font font{ FontMethod::MSDF, 48, Typeface::Bold };

	// アプリが同梱するフォントや素材のライセンスを、assets/licenses/*.txt から一覧に追加する (assets/licenses/README.md)
	LicenseManager::AddLicenseFiles(U"assets/licenses");

	// ライセンス一覧 (Android / iOS はアプリ内に表示、それ以外はブラウザで開く。LicenseView.hpp を参照)
	LicenseView licenseView;

	Scene::SetBackground(ColorF{ 0.6, 0.8, 0.7 });

	while (System::Update())
	{
		if (licenseView.isOpen())
		{
			licenseView.update();
			continue;
		}

		texture.drawAt(Scene::Center());
		font(U"Hello, Siv3D!").drawAt(40, Vec2{ Scene::Center().x, 60 }, ColorF{ 0.1 });

		if (SimpleGUI::Button(U"Licenses", Vec2{ (Scene::Width() - 140), (Scene::Height() - 50) }, 120))
		{
			licenseView.open();
		}

		Circle{ Cursor::Pos(), 40 }.draw(ColorF{ 1.0, 0.0, 0.0, 0.5 });
	}
}
