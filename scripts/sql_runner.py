"""
Deprecated SQL runner.

This project now routes Snowflake access through Frosty MCP so application
queries always use the same read-only enforcement layer.
"""

import sys


def main():
    print(
        "Direct Snowflake connector auth is disabled for this project.\n"
        "Use Frosty MCP instead: http://localhost:8888/mcp",
        file=sys.stderr,
    )
    raise SystemExit(1)


if __name__ == "__main__":
    main()
