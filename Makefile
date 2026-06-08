.PHONY: dependencies test warnings validate

dependencies:
	swift package resolve
	swift package show-dependencies

test:
	swift test

warnings:
	swift test -Xswiftc -warnings-as-errors

validate: dependencies test warnings
