travis_install() {
	sudo wget https://github.com/dalance/svlint/releases/download/v0.5.0/svlint-v0.5.0-x86_64-lnx.zip
	sudo unzip svlint*
}

travis_script() {
	svlint ./*

}