package domains

import (
	"context"
	"xenixmail-core/api/domains/v1"
	"xenixmail-core/internal/service/mail_service"
	"xenixmail-core/internal/service/public"
)

func (c *ControllerV1) GetSSL(ctx context.Context, req *v1.GetSSLReq) (res *v1.GetSSLRes, err error) {
	res = &v1.GetSSLRes{}

	crt := mail_service.NewCertificate()
	defer crt.Close()

	// Get SSL certificate information
	res.Data, _ = crt.GetSSLInfo(public.FormatMX(req.Domain))

	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
