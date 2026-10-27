package domains

import (
	"context"
	"xenixmail-core/api/domains/v1"
	"xenixmail-core/internal/service/public"

	"github.com/gogf/gf/v2/os/gfile"
)

func (c *ControllerV1) GetBlocklistCheckLogs(ctx context.Context, req *v1.GetBlocklistCheckLogsReq) (res *v1.GetBlocklistCheckLogsRes, err error) {
	res = &v1.GetBlocklistCheckLogsRes{}
	logPath := req.Path
	if !gfile.Exists(logPath) {
		res.Data = ""
		res.SetSuccess(public.LangCtx(ctx, "Success"))
		return
	}

	res.Data = gfile.GetContents(logPath)
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
