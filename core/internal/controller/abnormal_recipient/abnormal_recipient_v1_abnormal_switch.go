package abnormal_recipient

import (
	"context"
	"strconv"
	"xenixmail-core/api/abnormal_recipient/v1"
	"xenixmail-core/internal/service/public"
)

func (c *ControllerV1) AbnormalSwitch(ctx context.Context, req *v1.AbnormalSwitchReq) (res *v1.AbnormalSwitchRes, err error) {
	res = &v1.AbnormalSwitchRes{}

	abnormalSwitch := GetAbnormalSwitch()

	res.Data, _ = strconv.Atoi(abnormalSwitch)
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
