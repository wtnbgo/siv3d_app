# include <Siv3D.hpp>

void Main()
{
	// アセットはカレントディレクトリ (実行ファイルのフォルダ) からの相対パスで読む
	// (siv3d-app.json の "assets" で assets/ を実行ファイルの隣にコピーしている)
	const Texture texture{ U"assets/windmill.png" };
	const Font font{ FontMethod::MSDF, 48, Typeface::Bold };

	Scene::SetBackground(ColorF{ 0.6, 0.8, 0.7 });

	while (System::Update())
	{
		texture.drawAt(Scene::Center());
		font(U"Hello, Siv3D!").drawAt(40, Vec2{ Scene::Center().x, 60 }, ColorF{ 0.1 });
		Circle{ Cursor::Pos(), 40 }.draw(ColorF{ 1.0, 0.0, 0.0, 0.5 });
	}
}
