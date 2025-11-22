try:
    from app import app
except Exception as e:
    print("ERROR importing app:", e)
    raise SystemExit(1)

for rule in sorted(app.url_map.iter_rules(), key=lambda r: str(r)):
    methods = ",".join(sorted(rule.methods - {"HEAD","OPTIONS"}))
    print(f"{rule.rule:30}  ->  {methods}")
